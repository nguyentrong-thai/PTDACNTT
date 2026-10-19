require('dotenv').config();
const bcrypt = require('bcrypt');
const { pool } = require('../config/db');
const { isValidPassword } = require('../utils/passwordPolicy');

async function createAdmin() {
  const fullName = typeof process.env.ADMIN_NAME === 'string' ? process.env.ADMIN_NAME.trim() : '';
  const email = typeof process.env.ADMIN_EMAIL === 'string' ? process.env.ADMIN_EMAIL.trim().toLowerCase() : '';
  const password = process.env.ADMIN_PASSWORD;

  if (!fullName || fullName.length > 100 || !/^\S+@\S+\.\S+$/.test(email) || email.length > 150) {
    throw new Error('Set a valid ADMIN_NAME and ADMIN_EMAIL before creating the administrator.');
  }
  if (!isValidPassword(password)) {
    throw new Error('ADMIN_PASSWORD must contain at least 8 characters.');
  }

  const [existingUsers] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
  if (existingUsers.length) {
    throw new Error('An account with ADMIN_EMAIL already exists; no account was changed.');
  }

  const passwordHash = await bcrypt.hash(password, 12);
  await pool.query(
    'INSERT INTO users (full_name, email, password_hash, role) VALUES (?, ?, ?, ?)',
    [fullName, email, passwordHash, 'admin']
  );
  console.log('Administrator account created. Remove ADMIN_PASSWORD from the environment now.');
}

if (require.main === module) {
  createAdmin()
    .catch((error) => {
      console.error('Could not create administrator:', error.message);
      process.exitCode = 1;
    })
    .finally(() => pool.end());
}

module.exports = { createAdmin };
