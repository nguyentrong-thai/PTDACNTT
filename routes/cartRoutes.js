const express = require('express');
const ProductModel = require('../models/productModel');
const CartModel = require('../models/cartModel');
const { requireLogin } = require('../middlewares/authMiddleware');

const router = express.Router();

router.get('/', requireLogin, async (req, res, next) => {
  try {
    delete req.session.buyNow;
    const cart = await CartModel.findByUser(req.session.user.id);
    const total = cart.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0);
    res.render('cart/index', { title: 'Giỏ hàng - ElectroShop', cart, total });
  } catch (err) { next(err); }
});
router.post('/update/:id', requireLogin, async (req, res, next) => {
  try {
    const productId = Number(req.params.id);
    const requestedQuantity = Number(req.body.quantity);
    if (!Number.isSafeInteger(productId) || productId < 1 || !Number.isSafeInteger(requestedQuantity) || requestedQuantity < 1) {
      req.flash('error', 'Số lượng sản phẩm không hợp lệ.');
      return res.redirect('/cart');
    }
    const updated = await CartModel.updateQuantity(req.session.user.id, productId, requestedQuantity);
    req.flash(updated ? 'success' : 'error', updated ? 'Đã cập nhật giỏ hàng.' : 'Sản phẩm không còn khả dụng và đã được xóa khỏi giỏ hàng.');
    res.redirect('/cart');
  } catch (err) { next(err); }
});
router.post('/add', async (req, res, next) => {
  try {
    const productId = Number(req.body.product_id);
    const requestedQuantity = Number(req.body.quantity || 1);
    if (!Number.isSafeInteger(productId) || productId < 1 || !Number.isSafeInteger(requestedQuantity) || requestedQuantity < 1) {
      req.flash('error', 'Số lượng sản phẩm không hợp lệ.');
      return res.redirect('/products');
    }
    const product = await ProductModel.findById(productId);
    if (!product || product.stock_qty < 1) { req.flash('error', 'Sản phẩm hiện đã hết hàng.'); return res.redirect('/products'); }
    const quantity = Math.max(1, Math.min(Number.isSafeInteger(requestedQuantity) ? requestedQuantity : 1, product.stock_qty));
    const cartItem = { id: product.id, name: product.name, price: Number(product.price), image_url: product.image_url, quantity, stock_qty: product.stock_qty };
    if (req.body.intent === 'buy_now') {
      req.session.buyNow = cartItem;
      if (!req.session.user) {
        req.session.returnTo = '/orders/checkout';
        req.flash('success', 'Đăng nhập để tiếp tục thanh toán sản phẩm.');
        return res.redirect('/auth/login');
      }
      return res.redirect('/orders/checkout');
    }

    delete req.session.buyNow;
    if (!req.session.user) {
      req.flash('error', 'Vui lòng đăng nhập để sử dụng giỏ hàng.');
      return res.redirect('/auth/login');
    }
    const added = await CartModel.add(req.session.user.id, product.id, quantity);
    if (!added) {
      req.flash('error', 'Sản phẩm hiện đã hết hàng.');
      return res.redirect(`/products/${product.id}`);
    }
    req.flash('success', 'Đã thêm sản phẩm vào giỏ hàng.');
    res.redirect('/cart');
  } catch (err) { next(err); }
});
router.post('/remove/:id', requireLogin, async (req, res, next) => {
  try {
    const productId = Number(req.params.id);
    if (Number.isSafeInteger(productId) && productId > 0) await CartModel.remove(req.session.user.id, productId);
    res.redirect('/cart');
  } catch (err) { next(err); }
});

module.exports = router;