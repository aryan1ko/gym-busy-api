require('dotenv').config();
const express  = require('express');
const mongoose = require('mongoose');
const cors     = require('cors');
const jwt      = require('jsonwebtoken');

const User      = require('./models/User');
const DataPoint = require('./models/DataPoint');

const app = express();
app.use(cors());
app.use(express.json());

// 1) Connect to MongoDB
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));

// 2) Auth middleware
const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).send({ error: 'Missing token' });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload;
    next();
  } catch {
    res.status(401).send({ error: 'Invalid token' });
  }
};

// 3a) Register — run once to create your master account
app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;
  const user = new User({ username });
  await user.setPassword(password);
  await user.save();
  res.send({ success: true });
});

// 3b) Login
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  const user = await User.findOne({ username });
  if (!user || !(await user.validatePassword(password))) {
    return res.status(401).send({ error: 'Invalid credentials' });
  }
  const token = jwt.sign(
    { id: user._id, username },
    process.env.JWT_SECRET,
    { expiresIn: '12h' }
  );
  res.send({ token });
});

// 3c) GET /api/data?gym=<gymKey> + 1-minute synthetic fallback
app.get('/api/data', async (req, res) => {
  const { gym } = req.query;
  if (!gym) {
    return res
      .status(400)
      .send({ error: 'gym query parameter required.' });
  }

  // Fetch the last 96 real points
  const points = await DataPoint.find({ gym })
    .sort({ timestamp: 1 })
    .limit(96)
    .lean();

  // Clean timestamps, include gym/count
  const cleaned = points.map(p => ({
    _id:       p._id,
    gym:       p.gym,
    count:     p.count,
    timestamp: p.timestamp
      .toISOString()
      .replace(/\.\d+Z$/, 'Z'),
    __v:       p.__v
  }));

  // If the last real point is more than 1 minute ago, append a synthetic point
  if (cleaned.length) {
    const last     = cleaned[cleaned.length - 1];
    const lastDate = new Date(last.timestamp);
    const now      = new Date();
    const ONE_MIN  =  1 * 60 * 1000;

    if (now - lastDate > ONE_MIN) {
      const fallbackDate  = new Date(lastDate.getTime() + ONE_MIN);
      const fallbackCount = Math.max(0, last.count - 10);

      cleaned.push({
        _id:       mongoose.Types.ObjectId(),      // new ID
        gym:       last.gym,
        count:     fallbackCount,
        timestamp: fallbackDate
          .toISOString()
          .replace(/\.\d+Z$/, 'Z'),
        __v:       0,
        synthetic: true                           // flag if you want
      });
    }
  }

  // Return both real + synthetic
  res.json(cleaned);
});

// 3d) POST /api/data (auth required)
app.post('/api/data', auth, async (req, res) => {
  const { count, gym } = req.body;
  if (!gym) {
    return res.status(400).send({ error: 'Must include gym field.' });
  }
  const p = new DataPoint({ gym, count });
  await p.save();
  res.send({ success: true, point: p });
});

// 4) Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Listening on ${PORT}`));
