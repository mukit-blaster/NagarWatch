const mongoose = require('mongoose');

const evidenceSchema = new mongoose.Schema({
  projectId: { type: mongoose.Schema.Types.ObjectId, ref: 'Project', required: true },
  issueId: { type: mongoose.Schema.Types.ObjectId, ref: 'Issue' },
  uploadedBy: String,
  uploaderName: String,
  imageUrl: { type: String, required: true },
  latitude: Number,
  longitude: Number,
  timestamp: { type: Date, default: Date.now },
  status: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'pending' },
  rejectionReason: String,
}, { timestamps: true });

module.exports = mongoose.model('Evidence', evidenceSchema);
