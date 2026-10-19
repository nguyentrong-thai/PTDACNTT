const express = require('express');
const fs = require('fs');
const path = require('path');
const multer = require('multer');
const sharp = require('sharp');
const bcrypt = require('bcrypt');
const { pool } = require('../config/db');
const { requireStaff, requireAdmin } = require('../middlewares/authMiddleware');
const { isValidPassword } = require('../utils/passwordPolicy');
const { getAllowedOrderTransitions, isAllowedOrderTransition } = require('../utils/orderStatus');
const uploadDirectory = require('../config/uploadStorage');

const router = express.Router();
router.use(requireStaff);
router.use(['/users', '/staff', '/staffs', '/categories'], requireAdmin);

function getPage(value, limit) {
  const page = Math.max(1, Number.parseInt(value, 10) || 1);
  return { page, limit, offset: (page - 1) * limit };
}

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, callback) => {
    const extension = path.extname(file.originalname).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.webp'].includes(extension) && ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) return callback(null, true);
    callback(new Error('Chỉ được upload file hình ảnh.'));
  },
});

function handleImageUpload(req, res, next) {
  upload.single('image')(req, res, (error) => {
    if (!error) return next();
    req.flash('error', error.code === 'LIMIT_FILE_SIZE'
      ? 'Ảnh sản phẩm không được vượt quá 5 MB.'
      : 'Chỉ chấp nhận ảnh JPG, PNG hoặc WebP.');
    res.redirect(req.params.id ? `/admin/products/${req.params.id}/edit` : '/admin/products/new');
  });
}

async function saveUploadedImage(file) {
  if (!file) return null;
  const filename = `${Date.now()}-${Math.random().toString(36).slice(2)}.webp`;
  await sharp(file.buffer).rotate().resize({ width: 1600, height: 1600, fit: 'inside', withoutEnlargement: true }).webp({ quality: 82 }).toFile(path.join(uploadDirectory, filename));
  return `/images/products/${filename}`;
}

function getImageUrl(value) {
  if (typeof value !== 'string' || !value.trim()) return null;
  try {
    const url = new URL(value.trim(), 'http://localhost');
    if (url.origin === 'http://localhost' && value.trim().startsWith('/images/')) return value.trim();
    if (['http:', 'https:'].includes(url.protocol)) return url.href;
  } catch (err) {
    return null;
  }
  return null;
}

function validateProductInput({ name, category_id, price, stock_qty } = {}) {
  if (typeof name !== 'string' || !name.trim() || name.trim().length > 200) return null;
  if (typeof category_id !== 'string' || !category_id.trim()) return null;
  if (typeof price !== 'string' || !price.trim()) return null;
  if (typeof stock_qty !== 'string' || !stock_qty.trim()) return null;

  const categoryId = Number(category_id);
  const productPrice = Number(price);
  const stockQuantity = Number(stock_qty);
  if (!Number.isSafeInteger(categoryId) || categoryId < 1) return null;
  if (!Number.isFinite(productPrice) || productPrice < 0 || productPrice > 9999999999.99) return null;
  if (!Number.isSafeInteger(stockQuantity) || stockQuantity < 0 || stockQuantity > 2147483647) return null;

  return { name: name.trim(), categoryId, price: productPrice, stockQuantity };
}

function getCategoryInput({ name, slug, description } = {}) {
  if (typeof name !== 'string' || !name.trim() || name.trim().length > 100) return null;
  const normalizedSlug = typeof slug === 'string' && slug.trim()
    ? slug.trim().toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')
    : name.trim().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/gi, 'd').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  if (!normalizedSlug || normalizedSlug.length > 120) return null;
  return {
    name: name.trim(),
    slug: normalizedSlug,
    description: typeof description === 'string' && description.trim() ? description.trim() : null,
  };
}

function getEmployeeInput({ full_name, email, phone, address, gender, date_of_birth, position, password } = {}, { requirePassword = true } = {}) {
  if (typeof full_name !== 'string' || !full_name.trim() || full_name.trim().length > 100) return null;
  if (typeof email !== 'string' || !/^\S+@\S+\.\S+$/.test(email.trim()) || email.trim().length > 150) return null;
  if (typeof phone !== 'string' || !/^[0-9+()\-\s]{8,20}$/.test(phone.trim())) return null;
  if (typeof address !== 'string' || address.trim().length > 255) return null;
  if (typeof position !== 'string' || !position.trim() || position.trim().length > 100) return null;
  if (gender && !['male', 'female', 'other'].includes(gender)) return null;
  if (date_of_birth) {
    const parsedDate = new Date(`${date_of_birth}T00:00:00Z`);
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date_of_birth) || Number.isNaN(parsedDate.getTime()) || parsedDate.toISOString().slice(0, 10) !== date_of_birth) return null;
  }
  if (requirePassword && !isValidPassword(password)) return null;
  if (!requirePassword && password && !isValidPassword(password)) return null;
  return {
    fullName: full_name.trim(),
    email: email.trim().toLowerCase(),
    phone: phone.trim() || null,
    address: address.trim() || null,
    gender: gender || null,
    dateOfBirth: date_of_birth || null,
    position: position.trim(),
    password: password || null,
  };
}

async function updateOrderStatus(orderId, status) {
  let connection;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();
    const [[order]] = await connection.query('SELECT id, status FROM orders WHERE id = ? FOR UPDATE', [orderId]);
    if (!order) {
      await connection.rollback();
      return 'not_found';
    }
    if (!isAllowedOrderTransition(order.status, status)) {
      await connection.rollback();
      return 'invalid_transition';
    }
    if (order.status !== status && status === 'cancelled') {
      const [items] = await connection.query('SELECT product_id, quantity FROM order_items WHERE order_id = ?', [order.id]);
      for (const item of items) {
        await connection.query('UPDATE products SET stock_qty = stock_qty + ? WHERE id = ?', [item.quantity, item.product_id]);
      }
    }
    await connection.query('UPDATE orders SET status = ? WHERE id = ?', [status, order.id]);
    await connection.commit();
    return 'updated';
  } catch (error) {
    if (connection) await connection.rollback();
    throw error;
  } finally {
    if (connection) connection.release();
  }
}

router.get('/', async (req, res, next) => {
  try {
    const [[products]] = await pool.query('SELECT COUNT(*) AS count FROM products WHERE is_active = 1');
    const [[orders]] = await pool.query('SELECT COUNT(*) AS count FROM orders');
    const [[users]] = await pool.query('SELECT COUNT(*) AS count FROM users');
    res.render('admin/index', { title: 'Quản trị - ElectroShop', stats: { products: products.count, orders: orders.count, users: users.count } });
  } catch (err) { next(err); }
});

router.get('/products', async (req, res, next) => {
  try {
    const { page, limit } = getPage(req.query.page, 12);
    const [[count]] = await pool.query('SELECT COUNT(*) AS total FROM products');
    const total = Number(count.total);
    const totalPages = Math.max(1, Math.ceil(total / limit));
    const currentPage = Math.min(page, totalPages);
    const [products] = await pool.query(
      `SELECT p.*, c.name AS category_name
       FROM products p JOIN categories c ON c.id = p.category_id
       ORDER BY p.is_active DESC, p.created_at DESC LIMIT ? OFFSET ?`, [limit, (currentPage - 1) * limit]
    );
     res.render('admin/products', { title: 'Quản lý sản phẩm', products, pagination: { currentPage, totalPages, total, path: '/admin/products', query: {} } });
  } catch (err) { next(err); }
});

router.get('/users', async (req, res, next) => {
  try {
    const [employees] = await pool.query(
      "SELECT id, full_name, email, phone, address, gender, date_of_birth, position, role, created_at FROM users WHERE role = 'employee' ORDER BY created_at DESC"
    );
    res.render('admin/users', { title: 'Quản lý nhân viên', employees });
  } catch (err) { next(err); }
});

router.get('/staff', (req, res) => res.redirect('/admin/users'));

router.get('/users/new', (req, res) => {
  res.render('admin/employee-form', { title: 'Thêm nhân viên', employee: {}, formAction: '/admin/users' });
});

router.post('/users', async (req, res, next) => {
  try {
    const employee = getEmployeeInput(req.body);
    if (!employee) {
      req.flash('error', 'Vui lòng nhập họ tên, email và mật khẩu hợp lệ.');
      return res.redirect('/admin/users/new');
    }
    const passwordHash = await bcrypt.hash(employee.password, 12);
    await pool.query(
      'INSERT INTO users (full_name, email, password_hash, phone, address, gender, date_of_birth, position, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'employee\')',
      [employee.fullName, employee.email, passwordHash, employee.phone, employee.address, employee.gender, employee.dateOfBirth, employee.position]
    );
    req.flash('success', 'Đã thêm tài khoản nhân viên.');
    res.redirect('/admin/users');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      req.flash('error', 'Email hoặc số điện thoại nhân viên đã tồn tại.');
      return res.redirect('/admin/users/new');
    }
    next(err);
  }
});

router.get('/users/:id/edit', async (req, res, next) => {
  try {
    const [[employee]] = await pool.query(
      "SELECT id, full_name, email, phone, address, gender, date_of_birth, position, role FROM users WHERE id = ? AND role = 'employee'",
      [req.params.id]
    );
    if (!employee) return res.status(404).render('404', { title: 'Không tìm thấy nhân viên' });
    res.render('admin/employee-form', { title: 'Sửa nhân viên', employee, formAction: `/admin/users/${employee.id}/update` });
  } catch (err) { next(err); }
});

router.post('/users/:id/update', async (req, res, next) => {
  try {
    const employee = getEmployeeInput(req.body, { requirePassword: false });
    if (!employee) {
      req.flash('error', 'Vui lòng nhập thông tin nhân viên hợp lệ.');
      return res.redirect(`/admin/users/${req.params.id}/edit`);
    }
    const [[existing]] = await pool.query("SELECT id FROM users WHERE id = ? AND role = 'employee'", [req.params.id]);
    if (!existing) return res.status(404).render('404', { title: 'Không tìm thấy nhân viên' });
    if (employee.password) {
      const passwordHash = await bcrypt.hash(employee.password, 12);
      await pool.query(
        'UPDATE users SET full_name = ?, email = ?, password_hash = ?, phone = ?, address = ?, gender = ?, date_of_birth = ?, position = ? WHERE id = ? AND role = \'employee\'',
        [employee.fullName, employee.email, passwordHash, employee.phone, employee.address, employee.gender, employee.dateOfBirth, employee.position, req.params.id]
      );
    } else {
      await pool.query(
        'UPDATE users SET full_name = ?, email = ?, phone = ?, address = ?, gender = ?, date_of_birth = ?, position = ? WHERE id = ? AND role = \'employee\'',
        [employee.fullName, employee.email, employee.phone, employee.address, employee.gender, employee.dateOfBirth, employee.position, req.params.id]
      );
    }
    req.flash('success', 'Đã cập nhật tài khoản nhân viên.');
    res.redirect('/admin/users');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      req.flash('error', 'Email hoặc số điện thoại nhân viên đã tồn tại.');
      return res.redirect(`/admin/users/${req.params.id}/edit`);
    }
    next(err);
  }
});

router.post('/users/:id/delete', async (req, res, next) => {
  try {
    await pool.query("DELETE FROM users WHERE id = ? AND role = 'employee'", [req.params.id]);
    req.flash('success', 'Đã xóa tài khoản nhân viên.');
    res.redirect('/admin/users');
  } catch (err) { next(err); }
});

router.get('/products/new', async (req, res, next) => {
  try {
    const [categories] = await pool.query('SELECT id, name FROM categories ORDER BY name');
    res.render('admin/product-form', { title: 'Thêm sản phẩm', product: {}, categories, formAction: '/admin/products' });
  } catch (err) { next(err); }
});

router.post('/products', handleImageUpload, async (req, res, next) => {
  try {
    const { name, category_id, brand, description, price, stock_qty, image_url } = req.body;
    const product = validateProductInput({ name, category_id, price, stock_qty });
    if (!product) {
      req.flash('error', 'Vui lòng nhập tên, danh mục, giá và tồn kho hợp lệ.');
      return res.redirect('/admin/products/new');
    }
    const imageUrl = await saveUploadedImage(req.file);
    await pool.query(
      `INSERT INTO products (category_id, name, brand, description, price, stock_qty, image_url)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [product.categoryId, product.name, brand || null, description || null, product.price, product.stockQuantity, imageUrl || getImageUrl(image_url)]
    );
    req.flash('success', 'Đã thêm sản phẩm.');
    res.redirect('/admin/products');
  } catch (err) { next(err); }
});

router.get('/products/:id/edit', async (req, res, next) => {
  try {
    const [[product]] = await pool.query('SELECT * FROM products WHERE id = ?', [req.params.id]);
    const [categories] = await pool.query('SELECT id, name FROM categories ORDER BY name');
    if (!product) return res.status(404).render('404', { title: 'Không tìm thấy sản phẩm' });
    res.render('admin/product-form', { title: 'Sửa sản phẩm', product, categories, formAction: `/admin/products/${product.id}/update` });
  } catch (err) { next(err); }
});

router.post('/products/:id/update', handleImageUpload, async (req, res, next) => {
  try {
    const { name, category_id, brand, description, price, stock_qty, image_url } = req.body;
    const product = validateProductInput({ name, category_id, price, stock_qty });
    if (!product) {
      req.flash('error', 'Vui lòng nhập tên, danh mục, giá và tồn kho hợp lệ.');
      return res.redirect(`/admin/products/${req.params.id}/edit`);
    }
    const [[currentProduct]] = await pool.query('SELECT image_url FROM products WHERE id = ?', [req.params.id]);
    if (!currentProduct) return res.status(404).render('404', { title: 'Không tìm thấy sản phẩm' });
    const finalImageUrl = await saveUploadedImage(req.file) || getImageUrl(image_url) || currentProduct.image_url || null;
    await pool.query(
      `UPDATE products SET category_id = ?, name = ?, brand = ?, description = ?, price = ?, stock_qty = ?, image_url = ? WHERE id = ?`,
      [product.categoryId, product.name, brand || null, description || null, product.price, product.stockQuantity, finalImageUrl, req.params.id]
    );
    req.flash('success', 'Đã cập nhật sản phẩm.');
    res.redirect('/admin/products');
  } catch (err) { next(err); }
});

router.post('/products/:id/delete', async (req, res, next) => {
  try {
    const [[product]] = await pool.query('SELECT id FROM products WHERE id = ?', [req.params.id]);
    if (!product) {
      req.flash('error', 'Không tìm thấy sản phẩm.');
      return res.redirect('/admin/products');
    }
    const [[orderReference]] = await pool.query('SELECT COUNT(*) AS total FROM order_items WHERE product_id = ?', [req.params.id]);
    if (Number(orderReference.total)) {
      req.flash('error', 'Không thể xóa sản phẩm đã có trong đơn hàng.');
      return res.redirect('/admin/products');
    }
    await pool.query('DELETE FROM products WHERE id = ?', [req.params.id]);
    req.flash('success', 'Đã xóa sản phẩm.');
    res.redirect('/admin/products');
  } catch (err) {
    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
      req.flash('error', 'Không thể xóa sản phẩm đã có trong đơn hàng.');
      return res.redirect('/admin/products');
    }
    next(err);
  }
});

router.get('/categories', async (req, res, next) => {
  try {
    const [categories] = await pool.query('SELECT * FROM categories ORDER BY name');
    res.render('admin/categories', { title: 'Quản lý danh mục', categories });
  } catch (err) { next(err); }
});

router.get('/categories/:id/edit', async (req, res, next) => {
  try {
    const [[category]] = await pool.query('SELECT * FROM categories WHERE id = ?', [req.params.id]);
    if (!category) return res.status(404).render('404', { title: 'Không tìm thấy danh mục' });
    res.render('admin/category-form', { title: 'Sửa danh mục', category, formAction: `/admin/categories/${category.id}/update` });
  } catch (err) { next(err); }
});

router.post('/categories', async (req, res, next) => {
  try {
    const category = getCategoryInput(req.body);
    if (!category) {
      req.flash('error', 'Vui lòng nhập tên danh mục hợp lệ.');
      return res.redirect('/admin/categories');
    }
    await pool.query('INSERT INTO categories (name, slug, description) VALUES (?, ?, ?)', [category.name, category.slug, category.description]);
    req.flash('success', 'Đã thêm danh mục.');
    res.redirect('/admin/categories');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      req.flash('error', 'Tên hoặc slug danh mục đã tồn tại.');
      return res.redirect('/admin/categories');
    }
    next(err);
  }
});

router.post('/categories/:id/update', async (req, res, next) => {
  try {
    const category = getCategoryInput(req.body);
    if (!category) {
      req.flash('error', 'Vui lòng nhập tên danh mục hợp lệ.');
      return res.redirect(`/admin/categories/${req.params.id}/edit`);
    }
    await pool.query('UPDATE categories SET name = ?, slug = ?, description = ? WHERE id = ?', [category.name, category.slug, category.description, req.params.id]);
    req.flash('success', 'Đã cập nhật danh mục.');
    res.redirect('/admin/categories');
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      req.flash('error', 'Tên hoặc slug danh mục đã tồn tại.');
      return res.redirect(`/admin/categories/${req.params.id}/edit`);
    }
    next(err);
  }
});

router.post('/categories/:id/delete', async (req, res, next) => {
  try {
    await pool.query('DELETE FROM categories WHERE id = ?', [req.params.id]);
    req.flash('success', 'Đã xóa danh mục.');
    res.redirect('/admin/categories');
  } catch (err) {
    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
      req.flash('error', 'Không thể xóa danh mục đang có sản phẩm.');
      return res.redirect('/admin/categories');
    }
    next(err);
  }
});

router.get('/orders', async (req, res, next) => {
  try {
    const { page, limit } = getPage(req.query.page, 10);
    const [[count]] = await pool.query('SELECT COUNT(*) AS total FROM orders');
    const total = Number(count.total);
    const totalPages = Math.max(1, Math.ceil(total / limit));
    const currentPage = Math.min(page, totalPages);
    const [orders] = await pool.query(
      `SELECT o.*, u.full_name, u.email FROM orders o JOIN users u ON u.id = o.user_id ORDER BY o.created_at DESC LIMIT ? OFFSET ?`, [limit, (currentPage - 1) * limit]
    );
    orders.forEach((order) => {
      order.allowedTransitions = getAllowedOrderTransitions(order.status);
    });
    res.render('admin/orders', { title: 'Quản lý đơn hàng', orders, pagination: { currentPage, totalPages, total, path: '/admin/orders', query: {} } });
  } catch (err) { next(err); }
});

router.post('/orders/:id/status', async (req, res, next) => {
  try {
    const validStatuses = ['pending', 'confirmed', 'shipping', 'completed', 'cancelled'];
    if (!validStatuses.includes(req.body.status)) {
      req.flash('error', 'Trạng thái đơn hàng không hợp lệ.');
      return res.redirect('/admin/orders');
    }
    const result = await updateOrderStatus(req.params.id, req.body.status);
    if (result === 'not_found') {
      req.flash('error', 'Không tìm thấy đơn hàng.');
      return res.redirect('/admin/orders');
    }
    if (result === 'invalid_transition') {
      req.flash('error', 'Không thể chuyển đơn hàng sang trạng thái đã chọn.');
      return res.redirect('/admin/orders');
    }
    req.flash('success', 'Đã cập nhật trạng thái đơn hàng.');
    res.redirect('/admin/orders');
  } catch (err) {
    next(err);
  }
});

// Compatibility routes matching the reference project's admin URLs.
router.get('/dashboard', (req, res) => res.redirect('/admin'));
router.get('/staffs', (req, res) => res.redirect('/admin/users'));
router.get('/staffs/add', (req, res) => res.redirect('/admin/users/new'));
router.get('/staffs/edit/:id', (req, res) => res.redirect(`/admin/users/${req.params.id}/edit`));
router.post('/staffs/delete/:id', async (req, res, next) => {
  try {
    await pool.query("DELETE FROM users WHERE id = ? AND role = 'employee'", [req.params.id]);
    req.flash('success', 'Đã xóa tài khoản nhân viên.');
    res.redirect('/admin/users');
  } catch (err) { next(err); }
});
router.get('/products/add', (req, res) => res.redirect('/admin/products/new'));
router.get('/products/edit/:id', (req, res) => res.redirect(`/admin/products/${req.params.id}/edit`));
router.get('/categories/add', (req, res) => res.redirect('/admin/categories'));
router.get('/categories/edit/:id', (req, res) => res.redirect(`/admin/categories/${req.params.id}/edit`));
router.get('/bills', (req, res) => res.redirect('/admin/orders'));
router.get('/bills/:id', (req, res) => res.redirect(`/admin/orders/${req.params.id}`));
router.get('/bills/details/:id', (req, res) => res.redirect(`/admin/orders/${req.params.id}`));

router.get('/orders/:id', async (req, res, next) => {
  try {
    const [[order]] = await pool.query(
      `SELECT o.*, u.email FROM orders o JOIN users u ON u.id = o.user_id WHERE o.id = ?`,
      [req.params.id]
    );
    if (!order) return res.status(404).render('404', { title: 'Không tìm thấy đơn hàng' });
    const [items] = await pool.query(
      `SELECT oi.quantity, oi.unit_price, p.name FROM order_items oi JOIN products p ON p.id = oi.product_id WHERE oi.order_id = ?`,
      [req.params.id]
    );
    res.render('admin/order-detail', { title: `Chi tiết đơn hàng #${order.id}`, order, items });
  } catch (err) { next(err); }
});

router.post('/bills/approve/:id', async (req, res, next) => {
  try {
    const result = await updateOrderStatus(req.params.id, 'confirmed');
    if (result !== 'updated') {
      req.flash('error', result === 'not_found' ? 'Không tìm thấy đơn hàng.' : 'Chỉ đơn hàng chờ duyệt mới được duyệt.');
      return res.redirect('/admin/orders');
    }
    req.flash('success', 'Đã duyệt đơn hàng.');
    res.redirect('/admin/orders');
  } catch (err) { next(err); }
});

router.post('/bills/cancel/:id', async (req, res, next) => {
  let connection;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();
    const [[order]] = await connection.query(
      'SELECT id, status FROM orders WHERE id = ? FOR UPDATE',
      [req.params.id]
    );
    if (!order) {
      await connection.rollback();
      req.flash('error', 'Không tìm thấy đơn hàng.');
      return res.redirect('/admin/orders');
    }
    if (!['pending', 'confirmed'].includes(order.status)) {
      await connection.rollback();
      req.flash('error', 'Chỉ đơn hàng chờ duyệt hoặc đã xác nhận mới được hủy.');
      return res.redirect('/admin/orders');
    }

    const [items] = await connection.query(
      'SELECT product_id, quantity FROM order_items WHERE order_id = ?',
      [order.id]
    );
    for (const item of items) {
      await connection.query(
        'UPDATE products SET stock_qty = stock_qty + ? WHERE id = ?',
        [item.quantity, item.product_id]
      );
    }
    await connection.query(
      "UPDATE orders SET status = 'cancelled' WHERE id = ?",
      [order.id]
    );
    await connection.commit();
    req.flash('success', 'Đã hủy đơn hàng.');
    res.redirect('/admin/orders');
  } catch (err) {
    if (connection) await connection.rollback();
    next(err);
  } finally {
    if (connection) connection.release();
  }
});

module.exports = router;