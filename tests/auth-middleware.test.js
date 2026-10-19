const test = require('node:test');
const assert = require('node:assert/strict');
const { requireLogin, requireStaff, requireAdmin } = require('../middlewares/authMiddleware');

function invoke(middleware, user) {
  const redirects = [];
  const messages = [];
  let nextCalled = false;
  const req = {
    session: user ? { user } : {},
    flash: (...message) => messages.push(message),
  };
  const res = { redirect: (location) => redirects.push(location) };

  middleware(req, res, () => { nextCalled = true; });
  return { redirects, messages, nextCalled };
}

test('login middleware admits authenticated accounts only', () => {
  assert.deepEqual(invoke(requireLogin, null).redirects, ['/auth/login']);
  assert.equal(invoke(requireLogin, { id: 1, role: 'user' }).nextCalled, true);
});

test('staff middleware admits employee and admin, but not customers', () => {
  assert.equal(invoke(requireStaff, { id: 1, role: 'employee' }).nextCalled, true);
  assert.equal(invoke(requireStaff, { id: 1, role: 'admin' }).nextCalled, true);
  assert.deepEqual(invoke(requireStaff, { id: 1, role: 'user' }).redirects, ['/']);
  assert.deepEqual(invoke(requireStaff, null).redirects, ['/auth/login']);
});

test('admin middleware admits administrators only', () => {
  assert.equal(invoke(requireAdmin, { id: 1, role: 'admin' }).nextCalled, true);
  assert.deepEqual(invoke(requireAdmin, { id: 1, role: 'employee' }).redirects, ['/']);
  assert.deepEqual(invoke(requireAdmin, { id: 1, role: 'user' }).redirects, ['/']);
});
