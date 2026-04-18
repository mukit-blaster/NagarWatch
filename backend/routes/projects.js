const router = require('express').Router();
const { getDb } = require('../config/firebase');

const projectsCollection = () => getDb().collection('projects');
const withId = (doc) => ({ _id: doc.id, id: doc.id, ...doc.data() });
const sortByCreatedAtDesc = (items) =>
  items.sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());

// FR-2.3 Nearby projects
router.get('/nearby', async (req, res) => {
  try {
    const { lat, lng, radius = 5 } = req.query;
    if (lat === undefined || lng === undefined) return res.status(400).json({ message: 'lat and lng are required' });
    const delta = parseFloat(radius) / 111.0;
    const snap = await projectsCollection().get();
    const projects = sortByCreatedAtDesc(
      snap.docs.map(withId).filter((project) => {
        const pLat = Number(project.latitude);
        const pLng = Number(project.longitude);
        return (
          Number.isFinite(pLat) &&
          Number.isFinite(pLng) &&
          pLat >= parseFloat(lat) - delta &&
          pLat <= parseFloat(lat) + delta &&
          pLng >= parseFloat(lng) - delta &&
          pLng <= parseFloat(lng) + delta
        );
      })
    );
    res.json(projects);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// FR-2.3 Get all / by ward
router.get('/', async (req, res) => {
  try {
    let query = projectsCollection();
    if (req.query.wardId) query = query.where('wardId', '==', req.query.wardId);
    const snap = await query.get();
    const projects = sortByCreatedAtDesc(snap.docs.map(withId));
    res.json(projects);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const doc = await projectsCollection().doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({ message: 'Not found' });
    res.json(withId(doc));
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// FR-2.1 Create project
router.post('/', async (req, res) => {
  try {
    const now = new Date().toISOString();
    const ref = projectsCollection().doc();
    const payload = { ...req.body, createdAt: now, updatedAt: now };
    await ref.set(payload);
    const p = { _id: ref.id, id: ref.id, ...payload };
    res.status(201).json(p);
  } catch (err) { res.status(400).json({ message: err.message }); }
});

// FR-2.2 Update project
router.patch('/:id', async (req, res) => {
  try {
    const ref = projectsCollection().doc(req.params.id);
    const existing = await ref.get();
    if (!existing.exists) return res.status(404).json({ message: 'Not found' });

    await ref.update({ ...req.body, updatedAt: new Date().toISOString() });
    const updated = await ref.get();
    res.json(withId(updated));
  } catch (err) { res.status(400).json({ message: err.message }); }
});

module.exports = router;
