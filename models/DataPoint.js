const mongoose = require('mongoose');

const dataPointSchema = new mongoose.Schema({
  timestamp: { type: Date, default: () => new Date() },
  count: { type: Number, required: true },
});

module.exports = mongoose.model('DataPoint', dataPointSchema);
