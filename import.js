const mysql = require('mysql2/promise');
const fs = require('fs');
require('dotenv').config();

(async () => {
  const connectionUrl = process.env.DB_IMPORT_URL || process.env.MYSQL_URL || process.env.DATABASE_URL;
  const conn = await mysql.createConnection(connectionUrl || {
    host: process.env.MYSQLHOST || process.env.DB_HOST,
    port: Number(process.env.MYSQLPORT || process.env.DB_PORT || 3306),
    user: process.env.MYSQLUSER || process.env.DB_USER,
    password: process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || process.env.DB_PASS,
    database: process.env.MYSQLDATABASE || process.env.DB_NAME,
    multipleStatements: true,
    charset: 'utf8mb4',
  });

  try {
    await conn.query(fs.readFileSync('database/schema.sql', 'utf8'));
    console.log('Import xong');
  } finally {
    await conn.end();
  }
})().catch(e => { console.error(e.message); process.exit(1); });