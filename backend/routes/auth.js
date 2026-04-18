const router = require('express').Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { getDb } = require('../config/firebase');

const usersCollection = () => getDb().collection('users');

const withId = (doc) => ({ _id: doc.id, id: doc.id, ...doc.data() });

const sign = (user) => jwt.sign(
  { id: user._id, role: user.role },
  process.env.JWT_SECRET || 'secret',
  { expiresIn: '30d' }
);

const SUPER_ADMIN_EMAIL = (process.env.SUPER_ADMIN_EMAIL || 'admin@gmail.com').toLowerCase();
const SUPER_ADMIN_PASSWORD = process.env.SUPER_ADMIN_PASSWORD || 'admin@';

async function ensureSuperAdmin(email, password) {
  if (!email || !password) return null;
  const normalizedEmail = email.toLowerCase();
  if (normalizedEmail != SUPER_ADMIN_EMAIL || password != SUPER_ADMIN_PASSWORD) {
    return null;
  }

  const now = new Date().toISOString();
  const snap = await usersCollection().where('email', '==', normalizedEmail).limit(1).get();
  const hashedPassword = await bcrypt.hash(SUPER_ADMIN_PASSWORD, 10);

  if (snap.empty) {
    const userRef = usersCollection().doc();
    const user = {
      _id: userRef.id,
      id: userRef.id,
      name: 'Super Admin',
      email: normalizedEmail,
      phone: null,
      password: hashedPassword,
      role: 'admin',
      wardId: null,
      wardName: null,
      createdAt: now,
      updatedAt: now,
    };

    await userRef.set({
      name: user.name,
      email: user.email,
      phone: user.phone,
      password: user.password,
      role: user.role,
      wardId: user.wardId,
      wardName: user.wardName,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
    return user;
  }

  const existingDoc = snap.docs[0];
  await existingDoc.ref.update({
    role: 'admin',
    password: hashedPassword,
    updatedAt: now,
  });

  const updated = await existingDoc.ref.get();
  return withId(updated);
}

// FR-1.1 Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;
    if (!name || !email || !password) return res.status(400).json({ message: 'Name, email, and password required' });
    const normalizedEmail = email.toLowerCase();
    const existingSnap = await usersCollection().where('email', '==', normalizedEmail).limit(1).get();
    if (!existingSnap.empty) return res.status(409).json({ message: 'Email already registered' });

    const userRef = usersCollection().doc();
    const now = new Date().toISOString();
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = {
      _id: userRef.id,
      id: userRef.id,
      name,
      email: normalizedEmail,
      phone,
      password: hashedPassword,
      role: 'citizen',
      wardId: null,
      wardName: null,
      createdAt: now,
      updatedAt: now,
    };
    await userRef.set({
      name: user.name,
      email: user.email,
      phone: user.phone,
      password: user.password,
      role: user.role,
      wardId: user.wardId,
      wardName: user.wardName,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
    const token = sign(user);
    res.status(201).json({ _id: user._id, name, email: user.email, phone, role: user.role, token });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// FR-1.2 Login
router.post('/login', async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    const superAdmin = await ensureSuperAdmin(email, password);
    if (superAdmin) {
      const token = sign(superAdmin);
      return res.json({
        _id: superAdmin._id,
        name: superAdmin.name,
        email: superAdmin.email,
        phone: superAdmin.phone,
        role: superAdmin.role,
        wardId: superAdmin.wardId,
        wardName: superAdmin.wardName,
        token,
      });
    }

    let snap;
    if (email) {
      snap = await usersCollection().where('email', '==', email.toLowerCase()).limit(1).get();
    } else if (phone) {
      snap = await usersCollection().where('phone', '==', phone).limit(1).get();
    } else {
      return res.status(400).json({ message: 'Email or phone is required' });
    }

    if (snap.empty) return res.status(401).json({ message: 'Invalid credentials' });
    const user = withId(snap.docs[0]);
    if (!(await bcrypt.compare(password, user.password)))
      return res.status(401).json({ message: 'Invalid credentials' });

    const token = sign(user);
    res.json({ _id: user._id, name: user.name, email: user.email, phone: user.phone, role: user.role, wardId: user.wardId, wardName: user.wardName, token });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Helper function for approval requests collection
const approvalsCollection = () => getDb().collection('authority_approvals');

// FR-6.1 Authority Login
router.post('/authority-login', async (req, res) => {
  try {
    const { email, wardCode } = req.body;
    const superAdmin = await ensureSuperAdmin(email, wardCode);
    if (superAdmin) {
      const token = sign(superAdmin);
      return res.json({
        _id: superAdmin._id,
        name: superAdmin.name,
        email: superAdmin.email,
        role: superAdmin.role,
        wardId: superAdmin.wardId,
        wardName: superAdmin.wardName,
        token,
      });
    }

    const normalizedEmail = email.toLowerCase();
    const snap = await usersCollection().where('email', '==', normalizedEmail).limit(1).get();
    if (snap.empty) return res.status(401).json({ message: 'Invalid authority credentials' });

    const user = withId(snap.docs[0]);
    if (!['authority', 'admin'].includes(user.role)) return res.status(401).json({ message: 'Invalid authority credentials' });
    // wardCode acts as password for authority
    const valid = await bcrypt.compare(wardCode, user.password);
    if (!valid) return res.status(401).json({ message: 'Invalid ward code' });

    // Check if user is pending approval (authority but not yet admin)
    if (user.role === 'authority') {
      let approvalRequest = await approvalsCollection().where('userId', '==', user._id).where('status', '==', 'pending').limit(1).get();
      if (approvalRequest.empty) {
        // Create new approval request
        const reqRef = approvalsCollection().doc();
        await reqRef.set({
          userId: user._id,
          email: user.email,
          name: user.name,
          status: 'pending',
          requestedAt: new Date().toISOString(),
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });
        approvalRequest = await reqRef.get();
      }
      const approvalData = approvalRequest.docs[0]?.data() || {};
      return res.status(202).json({
        message: 'Pending admin approval',
        status: 'pending_approval',
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        wardId: user.wardId,
        wardName: user.wardName,
        approvalStatus: approvalData.status || 'pending',
      });
    }

    // User is admin, issue token
    const token = sign(user);
    res.json({ _id: user._id, name: user.name, email: user.email, role: user.role, wardId: user.wardId, wardName: user.wardName, token });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Admin: Get all pending authority approval requests
router.get('/approval-requests', async (req, res) => {
  try {
    const snap = await approvalsCollection().where('status', '==', 'pending').get();
    const requests = snap.docs.map(doc => ({ _id: doc.id, id: doc.id, ...doc.data() }));
    res.json(requests);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

// Admin: Approve authority
router.patch('/approval-requests/:requestId/approve', async (req, res) => {
  try {
    const { requestId } = req.params;
    const approvalRef = approvalsCollection().doc(requestId);
    const approvalDoc = await approvalRef.get();

    if (!approvalDoc.exists) return res.status(404).json({ message: 'Request not found' });

    const approvalData = approvalDoc.data();
    const userRef = usersCollection().doc(approvalData.userId);

    // Update user role to admin
    await userRef.update({ role: 'admin', updatedAt: new Date().toISOString() });
    // Update approval request status
    await approvalRef.update({ status: 'approved', approvedAt: new Date().toISOString(), updatedAt: new Date().toISOString() });

    const updatedUser = await userRef.get();
    res.json({ message: 'Authority approved as admin', user: withId(updatedUser) });
  } catch (err) { res.status(400).json({ message: err.message }); }
});

// Admin: Reject authority
router.patch('/approval-requests/:requestId/reject', async (req, res) => {
  try {
    const { requestId } = req.params;
    const { reason } = req.body;
    const approvalRef = approvalsCollection().doc(requestId);
    const approvalDoc = await approvalRef.get();

    if (!approvalDoc.exists) return res.status(404).json({ message: 'Request not found' });

    // Update approval request status
    await approvalRef.update({ status: 'rejected', reason, rejectedAt: new Date().toISOString(), updatedAt: new Date().toISOString() });

    res.json({ message: 'Authority request rejected' });
  } catch (err) { res.status(400).json({ message: err.message }); }

});

// FR-1.3 Ward selection
router.patch('/ward', async (req, res) => {
  try {
    const { userId, wardId, wardName } = req.body;
    const userRef = usersCollection().doc(userId);
    const doc = await userRef.get();
    if (!doc.exists) return res.status(404).json({ message: 'User not found' });

    await userRef.update({ wardId, wardName, updatedAt: new Date().toISOString() });
    const updated = await userRef.get();
    const user = withId(updated);
    res.json({ _id: user._id, name: user.name, email: user.email, role: user.role, wardId: user.wardId, wardName: user.wardName });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
