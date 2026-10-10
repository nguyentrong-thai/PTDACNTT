require('dotenv').config();
const express = require('express');
const path = require('path');
const session = require('express-session');
const flash = require('connect-flash');
const morgan = require('morgan');
const methodOverride = require('method-override');
const helmet = require('helmet');
const csrf = require('csurf');
const { rateLimit } = require('express-rate-limit');

const { testConnection } = require('./config/db');
const indexRoutes = require('./routes/index');
const profileRoutes = require('./routes/profileRoutes');
const CartModel = require('./models/cartModel');

const app = express();
const sessionSecret = process.env.SESSION_SECRET;

if (!sessionSecret) {
  throw new Error('SESSION_SECRET is required. Copy .env.example to .env and set a strong value.');
}

// ---------- View engine ----------
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// ---------- Middlewares ----------
app.use(morgan('dev'));
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      'img-src': ["'self'", 'data:', 'https://cdn.tgdd.vn', 'https://cdnv2.tgdd.vn'],
    },
  },
}));
app.use(express.urlencoded({ extended: true, limit: '100kb' }));
app.use(express.json({ limit: '100kb' }));
app.use(methodOverride('_method'));
app.use(express.static(path.join(__dirname, 'public')));

app.use(session({
  secret: sessionSecret,
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 1000 * 60 * 60 * 24,
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
  },
}));
app.use(flash());
app.use(csrf());

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: 'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
});

// Biến dùng chung cho mọi view (user đăng nhập, thông báo flash...)
app.use(async (req, res, next) => {
  try {
    res.locals.currentUser = req.session.user || null;
    res.locals.cartCount = req.session.user ? await CartModel.countQuantity(req.session.user.id) : 0;
    res.locals.success = req.flash('success');
    res.locals.error = req.flash('error');
    res.locals.csrfToken = req.csrfToken();
    res.locals.isAdminPage = req.path.startsWith('/admin');
    res.locals.currentPath = req.path;
    next();
  } catch (err) { next(err); }
});

// ---------- Routes ----------
app.use('/', indexRoutes);
app.use('/auth', authLimiter, require('./routes/authRoutes'));
app.use('/profile', profileRoutes);
app.use('/products', require('./routes/productRoutes'));
app.use('/cart', require('./routes/cartRoutes'));
app.use('/orders', require('./routes/orderRoutes'));
app.use('/wishlist', require('./routes/wishlistRoutes'));
app.use('/assistant', require('./routes/assistantRoutes'));
app.use('/admin', require('./routes/adminRoutes'));
app.get('/support', (req, res) => {
  res.render('support', { title: 'Trung tâm hỗ trợ - ElectroShop' });
});

// ---------- 404 ----------
app.use((req, res) => {
  res.status(404).render('404', { title: 'Không tìm thấy trang' });
});

app.use((err, req, res, next) => {
  if (err.code === 'EBADCSRFTOKEN') {
    return res.status(403).send('Yêu cầu không hợp lệ hoặc đã hết hạn. Vui lòng tải lại trang.');
  }
  if (err.statusCode === 413 || err.type === 'entity.too large') {
    return res.status(413).send('Dữ liệu gửi lên quá lớn.');
  }
  console.error(err);
  res.status(500).send('Đã xảy ra lỗi máy chủ. Vui lòng thử lại sau.');
});

// ---------- Khởi động server ----------
const PORT = process.env.PORT || 3000;
app.listen(PORT, async () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
  await testConnection();
});
