const express = require('express');
const { pool } = require('../config/db');
const UserModel = require('../models/userModel');
const CartModel = require('../models/cartModel');
const { requireLogin } = require('../middlewares/authMiddleware');

const router = express.Router();
router.use(requireLogin);

router.get('/checkout', async (req, res, next) => {
  try {
    let buyNowItem = req.session.buyNow;
    let cart;
    if (buyNowItem) {
      const [[product]] = await pool.query(
        'SELECT id, name, price, image_url, stock_qty, is_active FROM products WHERE id = ? AND is_active = 1',
        [buyNowItem.id]
      );
      if (!product || buyNowItem.quantity > product.stock_qty) {
        delete req.session.buyNow;
        req.flash('error', 'Sản phẩm không còn đủ số lượng trong kho.');
        return res.redirect('/products');
      }
      buyNowItem = { ...product, price: Number(product.price), quantity: buyNowItem.quantity };
      req.session.buyNow = buyNowItem;
      cart = [buyNowItem];
    } else {
      cart = await CartModel.findByUser(req.session.user.id);
    }
    if (!cart.length) { req.flash('error', 'Giỏ hàng đang trống.'); return res.redirect('/cart'); }
    if (cart.some((item) => !item.is_active || item.stock_qty < item.quantity)) {
      req.flash('error', 'Một số sản phẩm không còn đủ số lượng. Vui lòng cập nhật giỏ hàng.');
      return res.redirect('/cart');
    }
    const user = await UserModel.findById(req.session.user.id);
    const total = cart.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0);
    res.render('orders/checkout', { title: 'Thanh toán - ElectroShop', cart, total, user, isBuyNow: Boolean(buyNowItem) });
  } catch (err) { next(err); }
});

router.post('/checkout/cancel-buy-now', (req, res) => {
  delete req.session.buyNow;
  delete req.session.returnTo;
  res.redirect('/cart');
});

router.post('/', async (req, res, next) => {
  let connection;
  try {
    const buyNowItem = req.session.buyNow;
    let cart = buyNowItem ? [buyNowItem] : [];
    const recipientName = typeof req.body.recipient_name === 'string' ? req.body.recipient_name.trim() : '';
    const shippingAddress = typeof req.body.shipping_address === 'string' ? req.body.shipping_address.trim() : '';
    const shippingPhone = typeof req.body.shipping_phone === 'string' ? req.body.shipping_phone.trim() : '';
    const note = typeof req.body.note === 'string' ? req.body.note.trim() : '';
    if ((buyNowItem && (!Number.isSafeInteger(buyNowItem.id) || !Number.isSafeInteger(buyNowItem.quantity) || buyNowItem.quantity < 1)) || !recipientName || recipientName.length > 100 || !shippingAddress || shippingAddress.length > 255 || !/^[0-9+()\-\s]{8,20}$/.test(shippingPhone) || note.length > 255) {
      req.flash('error', 'Vui lòng nhập tên người nhận, địa chỉ và số điện thoại giao hàng hợp lệ.');
      return res.redirect('/orders/checkout');
    }
    connection = await pool.getConnection();
    await connection.beginTransaction();
    if (!buyNowItem) cart = await CartModel.findForCheckout(req.session.user.id, connection);
    if (!cart.length || cart.some((item) => !Number.isSafeInteger(item.quantity) || item.quantity < 1)) {
      throw new Error('Cart is empty or invalid');
    }
    let total = 0;
    const items = [];
    for (const cartItem of cart) {
      const [[product]] = await connection.query('SELECT id, price, stock_qty FROM products WHERE id = ? AND is_active = 1 FOR UPDATE', [cartItem.id]);
      if (!product || product.stock_qty < cartItem.quantity) throw new Error(`Sản phẩm ${cartItem.name} không đủ tồn kho.`);
      total += Number(product.price) * cartItem.quantity;
      items.push({ id: product.id, quantity: cartItem.quantity, price: Number(product.price) });
    }
    const [orderResult] = await connection.query(
      'INSERT INTO orders (user_id, recipient_name, total_amount, shipping_address, shipping_phone, note) VALUES (?, ?, ?, ?, ?, ?)',
      [req.session.user.id, recipientName, total, shippingAddress, shippingPhone, note || null]
    );
    for (const item of items) {
      await connection.query('INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)', [orderResult.insertId, item.id, item.quantity, item.price]);
      await connection.query('UPDATE products SET stock_qty = stock_qty - ? WHERE id = ?', [item.quantity, item.id]);
    }
    if (!buyNowItem) await CartModel.clear(req.session.user.id, connection);
    await connection.commit();
    if (buyNowItem) delete req.session.buyNow;
    delete req.session.returnTo;
    req.flash('success', `Đặt hàng thành công. Mã đơn #${orderResult.insertId}.`);
    res.redirect('/orders');
  } catch (err) {
    if (connection) await connection.rollback();
    req.flash('error', 'Không thể tạo đơn hàng. Vui lòng kiểm tra lại giỏ hàng và thông tin giao hàng.');
    res.redirect('/orders/checkout');
  } finally { if (connection) connection.release(); }
});

router.get('/', async (req, res, next) => {
  try {
    const page = Math.max(1, Number.parseInt(req.query.page, 10) || 1);
    const limit = 10;
    const validStatuses = ['pending', 'confirmed', 'shipping', 'completed', 'cancelled'];
    const status = validStatuses.includes(req.query.status) ? req.query.status : '';
    const whereStatus = status ? ' AND status = ?' : '';
    const queryValues = status ? [req.session.user.id, status] : [req.session.user.id];
    const [[count]] = await pool.query(`SELECT COUNT(*) AS total FROM orders WHERE user_id = ?${whereStatus}`, queryValues);
    const total = Number(count.total);
    const totalPages = Math.max(1, Math.ceil(total / limit));
    const currentPage = Math.min(page, totalPages);
    const [orders] = await pool.query(`SELECT * FROM orders WHERE user_id = ?${whereStatus} ORDER BY created_at DESC LIMIT ? OFFSET ?`, [...queryValues, limit, (currentPage - 1) * limit]);
    res.render('orders/index', { title: 'Đơn hàng của tôi', orders, status, pagination: { currentPage, totalPages, total, path: '/orders', query: status ? { status } : {} } });
  } catch (err) { next(err); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const [[order]] = await pool.query(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?',
      [req.params.id, req.session.user.id]
    );
    if (!order) return res.status(404).render('404', { title: 'Không tìm thấy đơn hàng' });
    const [items] = await pool.query(
      `SELECT oi.product_id, oi.quantity, oi.unit_price, p.name, p.image_url
       FROM order_items oi
       JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = ? ORDER BY oi.id`,
      [order.id]
    );
    res.render('orders/detail', { title: `Đơn hàng #${order.id}`, order, items });
  } catch (err) { next(err); }
});

router.post('/:id/cancel', async (req, res, next) => {
  let connection;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();
    const [[order]] = await connection.query(
      "SELECT id FROM orders WHERE id = ? AND user_id = ? AND status = 'pending' FOR UPDATE",
      [req.params.id, req.session.user.id]
    );
    if (order) {
      const [items] = await connection.query('SELECT product_id, quantity FROM order_items WHERE order_id = ?', [order.id]);
      for (const item of items) {
        await connection.query('UPDATE products SET stock_qty = stock_qty + ? WHERE id = ?', [item.quantity, item.product_id]);
      }
      await connection.query("UPDATE orders SET status = 'cancelled' WHERE id = ?", [order.id]);
    }
    await connection.commit();
    req.flash('success', 'Đã hủy đơn hàng nếu đơn chưa được xác nhận.');
    res.redirect('/orders');
  } catch (err) {
    if (connection) await connection.rollback();
    next(err);
  } finally { if (connection) connection.release(); }
});

module.exports = router;