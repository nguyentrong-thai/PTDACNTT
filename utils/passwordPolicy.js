const MIN_PASSWORD_LENGTH = 8;

function isValidPassword(password) {
  return typeof password === 'string' && password.length >= MIN_PASSWORD_LENGTH;
}

module.exports = { MIN_PASSWORD_LENGTH, isValidPassword };
