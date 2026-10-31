const express = require('express');
const { pool } = require('../config/db');
const { requireLogin } = require('../middlewares/authMiddleware');

const router = express.Router();
router.use(requireLogin);

function getReturnPath(req) {
  const referer = req.get('referer');
  if (!referer) return '/wishlist';
  try {
    const target = new URL(referer);
    if (target.host === req.get('host')) return `${target.pathname}${target.search}${target.hash}`;
  } catch (err) {
    return '/wishlist';
  }
  return '/wishlist';
}

router.get('/', async (req, res, next) => {
  try {
    const [products] = await pool.query(
      `SELECT p.id, p.name, p.brand, p.price, p.image_url, p.stock_qty
       FROM wishlist_items w JOIN products p ON p.id = w.product_id
       WHERE w.user_id = ? AND p.is_active = 1 ORDER BY w.created_at DESC`,
      [req.session.user.id]
    );
    res.render('wishlist/index', { title: 'Sản phẩm yêu thích', products });
  } catch (err) { next(err); }
});

router.post('/:productId/add', async (req, res, next) => {
  try {
    const [[product]] = await pool.query('SELECT id FROM products WHERE id = ? AND is_active = 1', [req.params.productId]);
    if (!product) {
      req.flash('error', 'Không tìm thấy sản phẩm để lưu.');
      return res.redirect('/products');
    }
    await pool.query('INSERT IGNORE INTO wishlist_items (user_id, product_id) VALUES (?, ?)', [req.session.user.id, product.id]);
    req.flash('success', 'Đã thêm sản phẩm vào danh sách yêu thích.');
    res.redirect(getReturnPath(req));
  } catch (err) { next(err); }
});

router.post('/:productId/remove', async (req, res, next) => {
  try {
    await pool.query('DELETE FROM wishlist_items WHERE user_id = ? AND product_id = ?', [req.session.user.id, req.params.productId]);
    req.flash('success', 'Đã xóa sản phẩm khỏi danh sách yêu thích.');
    res.redirect(getReturnPath(req));
  } catch (err) { next(err); }
});

module.exports = router;