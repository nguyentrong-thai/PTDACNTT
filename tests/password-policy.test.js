const test = require('node:test');
const assert = require('node:assert/strict');
const { MIN_PASSWORD_LENGTH, isValidPassword } = require('../utils/passwordPolicy');

test('password policy requires at least eight characters', () => {
  assert.equal(MIN_PASSWORD_LENGTH, 8);
  assert.equal(isValidPassword('1234567'), false);
  assert.equal(isValidPassword('12345678'), true);
  assert.equal(isValidPassword(''), false);
  assert.equal(isValidPassword(null), false);
});
