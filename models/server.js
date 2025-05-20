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

// 1) Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
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

// 3) Routes

// (a) Register — only run once to create your master account
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
  const token = jwt.sign({ id: user._id, username }, process.env.JWT_SECRET, { expiresIn: '12h' });
  res.send({ token });
});


// GET /api/data?gym=<gymKey>
app.get('/api/data', async (req, res) => {
  const { gym } = req.query;
  if (!gym) {
    return res.status(400).send({ error: 'gym query parameter required.' });
  }

  // Only fetch points tagged with that gym
  const points = await DataPoint.find({ gym })
    .sort({ timestamp: 1 })
    .limit(96)
    .lean();

  // Strip fractional seconds, explicitly include gym
  const cleaned = points.map(p => ({
    _id:       p._id,
    gym:       p.gym,
    count:     p.count,
    timestamp: p.timestamp
      .toISOString()
      .replace(/\.\d+Z$/, 'Z'),
    __v:       p.__v
  }));

  res.json(cleaned);
});

// (d) POST data (auth required)
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
