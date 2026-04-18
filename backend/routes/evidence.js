const router = require('express').Router();
const { getDb } = require('../config/firebase');

const evidenceCollection = () => getDb().collection('evidence');
const withId = (doc) => ({ _id: doc.id, id: doc.id, ...doc.data() });
const sortByTimestampDesc = (items) =>
  items.sort((a, b) => new Date(b.timestamp || 0).getTime() - new Date(a.timestamp || 0).getTime());

router.get('/', async (req, res) => {
  try {
    let query = evidenceCollection();
    if (req.query.projectId) query = query.where('projectId', '==', req.query.projectId);
    if (req.query.status) query = query.where('status', '==', req.query.status);
    const snap = await query.get();
    const evidence = sortByTimestampDesc(snap.docs.map(withId));
    res.json(evidence);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// FR-4.1 Upload evidence
router.post('/', async (req, res) => {
  try {
    const now = new Date().toISOString();
    const ref = evidenceCollection().doc();
    const payload = { ...req.body, timestamp: now, createdAt: now, updatedAt: now };
    await ref.set(payload);
    const ev = { _id: ref.id, id: ref.id, ...payload };
    res.status(201).json(ev);
  } catch (err) { res.status(400).json({ message: err.message }); }
});

// FR-6.4 Update evidence status
router.patch('/:id/status', async (req, res) => {
  try {
    const { status, rejectionReason } = req.body;
    const ref = evidenceCollection().doc(req.params.id);
    const existing = await ref.get();
    if (!existing.exists) return res.status(404).json({ message: 'Not found' });

    await ref.update({ status, rejectionReason, updatedAt: new Date().toISOString() });
    const ev = await ref.get();
    res.json(withId(ev));
  } catch (err) { res.status(400).json({ message: err.message }); }
});

module.exports = router;
