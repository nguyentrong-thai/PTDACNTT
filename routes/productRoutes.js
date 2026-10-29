const express = require('express');
const ProductModel = require('../models/productModel');
const { pool } = require('../config/db');
const { requireLogin } = require('../middlewares/authMiddleware');

const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const queryValue = (value) => typeof value === 'string' ? value.trim() : '';
    const filters = {
      search: queryValue(req.query.search),
      category: queryValue(req.query.category),
      brand: queryValue(req.query.brand),
    };
    const page = Math.max(1, Number.parseInt(req.query.page, 10) || 1);
    const limit = 12;
    const [productPage, categories, brands] = await Promise.all([ProductModel.findAll({ ...filters, page, limit }), ProductModel.getCategories(), ProductModel.getBrands()]);
    const totalPages = Math.max(1, Math.ceil(productPage.total / limit));
    res.render('products/index', { title: 'Sản phẩm - ElectroShop', products: productPage.rows, categories, brands, filters, pagination: { currentPage: productPage.currentPage, totalPages, total: productPage.total, query: filters, path: '/products' } });
  } catch (err) { next(err); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const product = await ProductModel.findById(req.params.id);
    if (!product) return res.status(404).render('404', { title: 'Không tìm thấy sản phẩm' });
    const productId = product.id;
    const userId = req.session.user && req.session.user.id;
    const [reviewsResult, summaryResult, currentReviewResult, purchaseResult, wishlistResult] = await Promise.all([
      pool.query(
        `SELECT r.rating, r.comment, r.created_at, u.full_name
         FROM reviews r JOIN users u ON u.id = r.user_id
         WHERE r.product_id = ? ORDER BY r.created_at DESC`, [productId]
      ),
      pool.query('SELECT COUNT(*) AS review_count, AVG(rating) AS average_rating FROM reviews WHERE product_id = ?', [productId]),
      userId
        ? pool.query('SELECT rating, comment FROM reviews WHERE product_id = ? AND user_id = ?', [productId, userId])
        : Promise.resolve([[]]),
      userId
        ? pool.query(
          `SELECT 1 FROM orders o JOIN order_items oi ON oi.order_id = o.id
           WHERE o.user_id = ? AND oi.product_id = ? AND o.status = 'completed' LIMIT 1`, [userId, productId]
        )
        : Promise.resolve([[]]),
      userId
        ? pool.query('SELECT 1 FROM wishlist_items WHERE user_id = ? AND product_id = ?', [userId, productId])
        : Promise.resolve([[]]),
    ]);
    const summary = summaryResult[0][0];
    res.render('products/detail', {
      title: `${product.name} - ElectroShop`,
      product,
      reviews: reviewsResult[0],
      reviewCount: summary.review_count,
      averageRating: Number(summary.average_rating || 0),
      currentReview: currentReviewResult[0][0] || null,
      canReview: purchaseResult[0].length > 0,
      isWishlisted: wishlistResult[0].length > 0,
    });
  } catch (err) { next(err); }
});

router.post('/:id/reviews', requireLogin, async (req, res, next) => {
  try {
    const product = await ProductModel.findById(req.params.id);
    const rating = Number(req.body.rating);
    const comment = typeof req.body.comment === 'string' ? req.body.comment.trim() : '';
    if (!product) return res.status(404).render('404', { title: 'Không tìm thấy sản phẩm' });
    if (!Number.isInteger(rating) || rating < 1 || rating > 5 || comment.length > 2000) {
      req.flash('error', 'Vui lòng chọn số sao từ 1 đến 5 và giữ bình luận dưới 2.000 ký tự.');
      return res.redirect(`/products/${product.id}#reviews`);
    }

    const [purchases] = await pool.query(
      `SELECT 1 FROM orders o JOIN order_items oi ON oi.order_id = o.id
       WHERE o.user_id = ? AND oi.product_id = ? AND o.status = 'completed' LIMIT 1`,
      [req.session.user.id, product.id]
    );
    if (!purchases.length) {
      req.flash('error', 'Chỉ khách đã mua và nhận sản phẩm mới có thể đánh giá.');
      return res.redirect(`/products/${product.id}#reviews`);
    }

    await pool.query(
      `INSERT INTO reviews (product_id, user_id, rating, comment) VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment)`,
      [product.id, req.session.user.id, rating, comment || null]
    );
    req.flash('success', 'Đã lưu đánh giá của bạn.');
    res.redirect(`/products/${product.id}#reviews`);
  } catch (err) { next(err); }
});

module.exports = router;