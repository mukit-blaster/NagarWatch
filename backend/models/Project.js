const mongoose = require('mongoose');

const milestoneSchema = new mongoose.Schema({
  id: String, title: String, targetDate: String,
  state: { type: String, enum: ['completed', 'current', 'pending'], default: 'pending' },
});

const projectSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: String,
  wardId: { type: String, required: true },
  wardName: String,
  location: String,
  latitude: { type: Number, default: 23.8103 },
  longitude: { type: Number, default: 90.4125 },
  geofenceRadius: { type: Number, default: 500 },
  budgetLakh: { type: Number, required: true },
  deadlineLabel: String,
  status: { type: String, enum: ['planned', 'ongoing', 'completed', 'delayed'], default: 'planned' },
  type: { type: String, enum: ['road', 'drainage', 'lighting', 'waste', 'park', 'building', 'other'], default: 'other' },
  progressPercent: { type: Number, default: 0, min: 0, max: 100 },
  contractorName: String,
  startDate: String,
  deadlineDate: String,
  priority: { type: String, enum: ['High', 'Medium', 'Low'], default: 'Medium' },
  milestones: [milestoneSchema],
  createdBy: String,
}, { timestamps: true });

module.exports = mongoose.model('Project', projectSchema);
