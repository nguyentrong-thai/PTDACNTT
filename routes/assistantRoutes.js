const express = require('express');
const { pool } = require('../config/db');
const { findRecommendations } = require('../utils/recommendations');

const router = express.Router();

router.post('/', async (req, res, next) => {
  try {
    const message = typeof req.body.message === 'string' ? req.body.message.trim() : '';
    if (!message) return res.status(400).json({ reply: 'Bạn muốn tìm sản phẩm nào?', products: [] });
    if (message.length > 200) {
      return res.status(400).json({ reply: 'Câu hỏi không được vượt quá 200 ký tự.', products: [] });
    }

    const [products] = await pool.query(
      `SELECT p.id, p.name, p.brand, p.price, p.image_url, p.stock_qty, c.name AS category_name
       FROM products p JOIN categories c ON c.id = p.category_id
       WHERE p.is_active = 1 AND p.stock_qty > 0 ORDER BY p.created_at DESC LIMIT 100`
    );
    const matched = findRecommendations(products, message);

    const reply = matched.length
      ? `Mình tìm được ${matched.length} sản phẩm phù hợp. Bạn có thể xem chi tiết bên dưới.`
      : 'Hiện chưa tìm thấy sản phẩm phù hợp. Bạn thử đổi từ khóa, danh mục hoặc mức giá nhé.';
    res.json({ reply, products: matched });
  } catch (err) { next(err); }
});

module.exports = router;