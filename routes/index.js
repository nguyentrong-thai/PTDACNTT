const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');

// Trang chủ: hiển thị danh mục + sản phẩm nổi bật
router.get('/', async (req, res, next) => {
  try {
    const [categories] = await pool.query(
      'SELECT id, name, slug, description FROM categories ORDER BY name'
    );
    const [products] = await pool.query(
      `SELECT id, name, brand, price, image_url, stock_qty
       FROM products
       WHERE is_active = 1
       ORDER BY created_at DESC
       LIMIT 8`
    );

    res.render('index', {
      title: 'Trang chủ - ElectroShop',
      marketHome: true,
      categories,
      products,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
