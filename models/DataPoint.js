// models/DataPoint.js
const mongoose = require('mongoose');

const dataPointSchema = new mongoose.Schema({
  gym: {
    type: String,
    required: true                    // every point must have a gym
  },
  timestamp: {
    type: Date,
    default: () => new Date()
  },
  count: {
    type: Number,
    required: true
  }
});

module.exports = mongoose.model('DataPoint', dataPointSchema);
