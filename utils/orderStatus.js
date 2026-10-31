const ORDER_STATUS_TRANSITIONS = Object.freeze({
  pending: Object.freeze(['confirmed', 'cancelled']),
  confirmed: Object.freeze(['shipping', 'cancelled']),
  shipping: Object.freeze(['completed']),
  completed: Object.freeze([]),
  cancelled: Object.freeze([]),
});

function getAllowedOrderTransitions(status) {
  return ORDER_STATUS_TRANSITIONS[status] || [];
}

function isAllowedOrderTransition(currentStatus, nextStatus) {
  if (!Object.prototype.hasOwnProperty.call(ORDER_STATUS_TRANSITIONS, currentStatus)) return false;
  return currentStatus === nextStatus || ORDER_STATUS_TRANSITIONS[currentStatus].includes(nextStatus);
}

module.exports = { ORDER_STATUS_TRANSITIONS, getAllowedOrderTransitions, isAllowedOrderTransition };
