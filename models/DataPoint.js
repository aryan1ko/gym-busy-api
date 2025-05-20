const mongoose = require('mongoose');

const dataPointSchema = new mongoose.Schema({
  gym: {
    type: String,
    required: true   // we now require the gym identifier
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

