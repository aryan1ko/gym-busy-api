require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const User = require('./models/User');
const DataPoint = require('./models/DataPoint');

const app = express();
app.use(cors());
app.use(express.json());

// 1) Connect to MongoDB and start gap-filler timer
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');

    // Every 15 minutes, insert a “-10” point if no update arrived
    const FIFTEEN_MIN = 15 * 60 * 1000;
    setInterval(async () => {
      try {
        // Get the very latest point
        const lastPoint = await DataPoint.findOne().sort({ timestamp: -1 });
        if (!lastPoint) return;

        const now = new Date();
        // If it's been more than 15m since lastPoint
        if (now - lastPoint.timestamp > FIFTEEN_MIN) {
          // Subtract 10 (floor at 0)
          const newCount = Math.max(lastPoint.count - 10, 0);
          const p = new DataPoint({ count: newCount });
          await p.save();
          console.log(`Gap-filled: inserted count=${newCount} at ${p.timestamp.toISOString()}`);
        }
      } catch (err) {
        console.error('Error in gap-filler:', err);
      }
    }, FIFTEEN_MIN);

  })
  .catch(err => console.error('MongoDB connection error:', err));

// 2) Auth middleware
const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).send({ error: 'Missing token' });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).send({ error: 'Invalid token' });
  }
};

// 3) Routes

// (a) Register — create your master account
app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;
  const user = new User({ username });
  await user.setPassword(password);
  await user.save();
  res.send({ success: true });
});

// (b) Login
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

// (c) GET data — strip fractional seconds
app.get('/api/data', async (req, res) => {
  const points = await DataPoint.find()
    .sort({ timestamp: 1 })
    .limit(96)
    .lean();

  const cleaned = points.map(p => ({
    ...p,
    timestamp: p.timestamp
      .toISOString()
      .replace(/\.\d+Z$/, 'Z')
  }));

  res.json(cleaned);
});

// (d) POST data (auth required)
app.post('/api/data', auth, async (req, res) => {
  const { count } = req.body;
  const p = new DataPoint({ count });
  await p.save();
  res.send({ success: true, point: p });
});

// 4) Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Listening on ${PORT}`));
