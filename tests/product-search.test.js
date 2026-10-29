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
    assert.match(calls[0].sql, /p\.name LIKE \? OR p\.brand LIKE \? OR p\.description LIKE \?/g);
    assert.equal((calls[0].sql.match(/p\.name LIKE \?/g) || []).length, 2);
    assert.deepEqual(calls[0].values, [
      '%iPhone%', '%iPhone%', '%iPhone%',
      '%15%', '%15%', '%15%',
    ]);
    assert.match(calls[1].sql, /WHEN p\.name = \? THEN 0/);
    assert.match(calls[1].sql, /WHEN p\.name LIKE \? THEN 1/);
    assert.deepEqual(calls[1].values, [
      '%iPhone%', '%iPhone%', '%iPhone%',
      '%15%', '%15%', '%15%',
      'iPhone 15', 'iPhone 15%', '%iPhone 15%', '%iPhone 15%',
      12, 12,
    ]);
  } finally {
    pool.query = originalQuery;
  }
});
