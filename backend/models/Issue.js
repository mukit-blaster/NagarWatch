const mongoose = require('mongoose');

const issueSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  imageUrl: String,
  areaName: { type: String, required: true },
  roadNumber: { type: String, required: true },
  wardId: String,
  wardNumber: String,
  reportedBy: String,
  latitude: Number,
  longitude: Number,
  status: { type: String, enum: ['submitted', 'inProgress', 'resolved'], default: 'submitted' },
}, { timestamps: true });

issueSchema.virtual('id').get(function() { return this._id.toHexString(); });
issueSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('Issue', issueSchema);
