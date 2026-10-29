const test = require('node:test');
const assert = require('node:assert/strict');
const { pool } = require('../config/db');
const ProductModel = require('../models/productModel');

test('product search matches every term and ranks name matches first', async () => {
  const originalQuery = pool.query;
  const calls = [];

  pool.query = async (sql, values) => {
    calls.push({ sql, values });
    return sql.includes('COUNT(*)')
      ? [[{ total: 15 }], []]
      : [[{ id: 1, name: 'iPhone Pro 15' }], []];
  };

  try {
    const result = await ProductModel.findAll({ search: '  iPhone   15  ', page: 2 });

    assert.equal(result.total, 15);
    assert.equal(result.currentPage, 2);
    assert.deepEqual(result.rows, [{ id: 1, name: 'iPhone Pro 15' }]);
    assert.match(calls[0].sql, /LOWER\(p\.name\) COLLATE utf8mb4_unicode_ci LIKE \? OR LOWER\(p\.brand\) COLLATE utf8mb4_unicode_ci LIKE \? OR LOWER\(p\.description\) COLLATE utf8mb4_unicode_ci LIKE \?/g);
    assert.equal((calls[0].sql.match(/LOWER\(p\.name\) COLLATE utf8mb4_unicode_ci LIKE \?/g) || []).length, 2);
    assert.deepEqual(calls[0].values, [
      '%iphone%', '%iphone%', '%iphone%',
      '%15%', '%15%', '%15%',
    ]);
    assert.match(calls[1].sql, /WHEN LOWER\(p\.name\) COLLATE utf8mb4_unicode_ci = \? THEN 0/);
    assert.match(calls[1].sql, /WHEN LOWER\(p\.name\) COLLATE utf8mb4_unicode_ci LIKE \? THEN 1/);
    assert.deepEqual(calls[1].values, [
      '%iphone%', '%iphone%', '%iphone%',
      '%15%', '%15%', '%15%',
      'iphone 15', 'iphone 15%', '%iphone 15%', '%iphone 15%',
      12, 12,
    ]);
  } finally {
    pool.query = originalQuery;
  }
});

test('suggestions search without Vietnamese accents and cap result count', async () => {
  const originalQuery = pool.query;
  let call;

  pool.query = async (sql, values) => {
    call = { sql, values };
    return [[{ id: 2, name: 'Điện thoại' }], []];
  };

  try {
    const result = await ProductModel.findSuggestions('DIEN   THOAI', 20);

    assert.deepEqual(result, [{ id: 2, name: 'Điện thoại' }]);
    assert.match(call.sql, /COLLATE utf8mb4_unicode_ci LIKE \?/);
    assert.deepEqual(call.values, [
      '%dien%', '%dien%', '%dien%',
      '%thoai%', '%thoai%', '%thoai%',
      'dien thoai', 'dien thoai%', '%dien thoai%',
      10,
    ]);
  } finally {
    pool.query = originalQuery;
  }
});
