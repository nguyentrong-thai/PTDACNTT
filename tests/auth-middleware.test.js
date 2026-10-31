const test = require('node:test');
const assert = require('node:assert/strict');
const { requireLogin, requireStaff, requireAdmin } = require('../middlewares/authMiddleware');
const UserModel = require('../models/userModel');

async function invoke(middleware, sessionUser, databaseUser = sessionUser) {
  const redirects = [];
  const messages = [];
  let nextCalled = false;
  let sessionDestroyed = false;
  const originalFindById = UserModel.findById;
  UserModel.findById = async () => databaseUser;
  const req = {
    session: {
      ...(sessionUser ? { user: { ...sessionUser } } : {}),
      destroy: (callback) => {
        sessionDestroyed = true;
        callback(null);
      },
    },
    flash: (...message) => messages.push(message),
  };
  const res = {
    clearCookie: () => {},
    redirect: (location) => redirects.push(location),
  };

  try {
    await middleware(req, res, () => { nextCalled = true; });
  } finally {
    UserModel.findById = originalFindById;
  }
  return { redirects, messages, nextCalled, sessionDestroyed };
}

test('login middleware admits authenticated accounts only', async () => {
  assert.deepEqual((await invoke(requireLogin, null)).redirects, ['/auth/login']);
  assert.equal((await invoke(requireLogin, { id: 1, role: 'user' })).nextCalled, true);
});

test('staff middleware checks the current database role', async () => {
  assert.equal((await invoke(requireStaff, { id: 1, role: 'employee' }, { id: 1, role: 'employee' })).nextCalled, true);
  assert.equal((await invoke(requireStaff, { id: 1, role: 'admin' }, { id: 1, role: 'admin' })).nextCalled, true);
  assert.deepEqual((await invoke(requireStaff, { id: 1, role: 'employee' }, { id: 1, role: 'user' })).redirects, ['/']);
  assert.deepEqual((await invoke(requireStaff, null)).redirects, ['/auth/login']);
});

test('admin middleware checks the current database role', async () => {
  assert.equal((await invoke(requireAdmin, { id: 1, role: 'admin' }, { id: 1, role: 'admin' })).nextCalled, true);
  assert.deepEqual((await invoke(requireAdmin, { id: 1, role: 'admin' }, { id: 1, role: 'employee' })).redirects, ['/']);
  assert.deepEqual((await invoke(requireAdmin, { id: 1, role: 'employee' }, { id: 1, role: 'user' })).redirects, ['/']);
});

test('staff middleware revokes sessions for deleted accounts', async () => {
  const result = await invoke(requireStaff, { id: 1, role: 'employee' }, null);
  assert.deepEqual(result.redirects, ['/auth/login']);
  assert.equal(result.sessionDestroyed, true);
});
