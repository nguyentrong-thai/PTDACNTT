const mysql = require('mysql2/promise');
require('dotenv').config();

const connectionUrl = process.env.DATABASE_URL || process.env.MYSQL_URL;
const connectionOptions = connectionUrl || {
  host: process.env.DB_HOST || process.env.MYSQLHOST || 'localhost',
  port: Number(process.env.DB_PORT || process.env.MYSQLPORT || 3306),
  user: process.env.DB_USER || process.env.MYSQLUSER || 'root',
  password: process.env.DB_PASSWORD || process.env.MYSQLPASSWORD || '',
  database: process.env.DB_NAME || process.env.MYSQLDATABASE || 'electro_shop',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};

const pool = mysql.createPool(connectionOptions);

async function testConnection() {
  const conn = await pool.getConnection();
  try {
    await conn.query('SELECT 1');
    console.log('Kết nối MySQL thành công.');
  } finally {
    conn.release();
  }
}

module.exports = { pool, testConnection };
