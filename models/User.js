const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  username: { type: String, unique: true, required: true },
  passwordHash: String,
});

// Password hashing helpers
userSchema.methods.setPassword = async function(rawPassword) {
  this.passwordHash = await bcrypt.hash(rawPassword, 10);
};
userSchema.methods.validatePassword = async function(raw) {
  return bcrypt.compare(raw, this.passwordHash);
};

module.exports = mongoose.model('User', userSchema);
