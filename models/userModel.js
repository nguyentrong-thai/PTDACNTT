const { pool } = require('../config/db');

const UserModel = {
  async findByEmail(email) {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0] || null;
  },

  async findByPhone(phone) {
    const [rows] = await pool.query('SELECT id FROM users WHERE phone = ?', [phone]);
    return rows[0] || null;
  },

  async findAuthById(id) {
    const [rows] = await pool.query(
      'SELECT id, full_name, email, password_hash FROM users WHERE id = ?',
      [id]
    );
    return rows[0] || null;
  },

  async findById(id) {
    const [rows] = await pool.query(
      'SELECT id, full_name, email, phone, address, gender, date_of_birth, role FROM users WHERE id = ?',
      [id]
    );
    return rows[0] || null;
  },

  async updateAccount(id, { full_name, email, phone, address, gender, date_of_birth, password_hash }) {
    const fields = [
      'full_name = ?',
      'email = ?',
      'phone = ?',
      'address = ?',
      'gender = ?',
      'date_of_birth = ?',
    ];
    const values = [full_name, email, phone || null, address || null, gender || null, date_of_birth || null];
    if (password_hash) {
      fields.push('password_hash = ?');
      values.push(password_hash);
    }
    values.push(id);
    await pool.query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, values);
  },

  async updatePassword(id, password_hash) {
    const [result] = await pool.query(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [password_hash, id]
    );
    return result.affectedRows === 1;
  },

  async create({ full_name, email, password_hash, phone, address, role = 'user' }) {
    const [result] = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, phone, address, role)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [full_name, email, password_hash, phone || null, address || null, role]
    );
    return result.insertId;
  },

  async findEmployees() {
    const [rows] = await pool.query(
      "SELECT id, full_name, email, phone, address, position, role, created_at FROM users WHERE role = 'employee' ORDER BY created_at DESC"
    );
    return rows;
  },

  async findEmployeeById(id) {
    const [rows] = await pool.query(
      "SELECT id, full_name, email, phone, address, position, role FROM users WHERE id = ? AND role = 'employee'",
      [id]
    );
    return rows[0] || null;
  },
};

module.exports = UserModel;
