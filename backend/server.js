require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { getDb } = require('./config/firebase');

const authRoutes = require('./routes/auth');
const projectRoutes = require('./routes/projects');
const issueRoutes = require('./routes/issues');
const evidenceRoutes = require('./routes/evidence');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Health check
app.get('/api/health', (_, res) => res.json({ status: 'ok', time: new Date().toISOString() }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/projects', projectRoutes);
app.use('/api/issues', issueRoutes);
app.use('/api/evidence', evidenceRoutes);

// Initialize Firebase and start server
try {
  getDb();
  console.log('Connected to Firebase Firestore');
  app.listen(PORT, () => console.log(`NagarWatch API running on port ${PORT}`));
} catch (err) {
  console.error('Firebase initialization error:', err);
  process.exit(1);
}
