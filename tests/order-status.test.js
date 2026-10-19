const test = require('node:test');
const assert = require('node:assert/strict');
const { getAllowedOrderTransitions, isAllowedOrderTransition } = require('../utils/orderStatus');

test('order status transitions match the documented workflow', () => {
  assert.deepEqual(getAllowedOrderTransitions('pending'), ['confirmed', 'cancelled']);
  assert.deepEqual(getAllowedOrderTransitions('confirmed'), ['shipping', 'cancelled']);
  assert.deepEqual(getAllowedOrderTransitions('shipping'), ['completed']);
  assert.deepEqual(getAllowedOrderTransitions('completed'), []);
  assert.deepEqual(getAllowedOrderTransitions('cancelled'), []);
});

test('invalid and terminal order transitions are rejected', () => {
  assert.equal(isAllowedOrderTransition('pending', 'confirmed'), true);
  assert.equal(isAllowedOrderTransition('confirmed', 'shipping'), true);
  assert.equal(isAllowedOrderTransition('shipping', 'completed'), true);
  assert.equal(isAllowedOrderTransition('pending', 'shipping'), false);
  assert.equal(isAllowedOrderTransition('shipping', 'cancelled'), false);
  assert.equal(isAllowedOrderTransition('completed', 'shipping'), false);
  assert.equal(isAllowedOrderTransition('unknown', 'pending'), false);
});
