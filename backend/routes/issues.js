const router = require('express').Router();
const { getDb } = require('../config/firebase');

const issuesCollection = () => getDb().collection('issues');
const withId = (doc) => ({ _id: doc.id, id: doc.id, ...doc.data() });
const sortByCreatedAtDesc = (items) =>
  items.sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());

// FR-5.1 Get issues (by ward)
router.get('/', async (req, res) => {
  try {
    let query = issuesCollection();
    if (req.query.wardId) query = query.where('wardId', '==', req.query.wardId);
    if (req.query.status) query = query.where('status', '==', req.query.status);
    const snap = await query.get();
    const issues = sortByCreatedAtDesc(snap.docs.map(withId));
    res.json(issues);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const doc = await issuesCollection().doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({ message: 'Not found' });
    res.json(withId(doc));
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// FR-5.1 Report issue
router.post('/', async (req, res) => {
  try {
    const now = new Date().toISOString();
    const ref = issuesCollection().doc();
    const payload = { ...req.body, createdAt: now, updatedAt: now };
    await ref.set(payload);
    const issue = { _id: ref.id, id: ref.id, ...payload };
    res.status(201).json(issue);
  } catch (err) { res.status(400).json({ message: err.message }); }
});

// FR-5.3 Update status
router.patch('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const ref = issuesCollection().doc(req.params.id);
    const existing = await ref.get();
    if (!existing.exists) return res.status(404).json({ message: 'Not found' });

    await ref.update({ status, updatedAt: new Date().toISOString() });
    const issue = await ref.get();
    res.json(withId(issue));
  } catch (err) { res.status(400).json({ message: err.message }); }
});

module.exports = router;
