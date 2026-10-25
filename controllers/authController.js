const bcrypt = require('bcrypt');
const UserModel = require('../models/userModel');
const { isValidPassword } = require('../utils/passwordPolicy');

function getLocalReturnPath(value) {
  if (typeof value !== 'string' || !value.startsWith('/') || value.startsWith('//') || value.includes('\\') || /[\u0000-\u001f]/.test(value)) {
    return null;
  }

  try {
    const target = new URL(value, 'http://localhost');
    return target.origin === 'http://localhost'
      ? `${target.pathname}${target.search}${target.hash}`
      : null;
  } catch (err) {
    return null;
  }
}

const authController = {
  // ---------- Hiển thị form ----------
  showRegister(req, res) {
    req.session.returnTo = getLocalReturnPath(req.query.returnTo) || req.session.returnTo;
    res.render('auth/register', { title: 'Đăng ký', authPage: true, returnTo: getLocalReturnPath(req.session.returnTo) });
  },

  showLogin(req, res) {
    req.session.returnTo = getLocalReturnPath(req.query.returnTo) || req.session.returnTo;
    res.render('auth/login', { title: 'Đăng nhập', authPage: true, returnTo: getLocalReturnPath(req.session.returnTo) });
  },

  // ---------- Xử lý đăng ký ----------
  async register(req, res, next) {
    try {
      const full_name = typeof req.body.full_name === 'string' ? req.body.full_name.trim() : '';
      const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
      const password = typeof req.body.password === 'string' ? req.body.password : '';
      const confirm_password = typeof req.body.confirm_password === 'string' ? req.body.confirm_password : '';
      const phone = typeof req.body.phone === 'string' ? req.body.phone.trim() : '';
      const address = typeof req.body.address === 'string' ? req.body.address.trim() : '';

      if (!full_name || full_name.length > 100 || !/^\S+@\S+\.\S+$/.test(email) || email.length > 150 || !phone || phone.length > 20 || !/^[0-9+()\-\s]{8,20}$/.test(phone) || address.length > 255) {
        req.flash('error', 'Vui lòng nhập họ tên, email và số điện thoại hợp lệ.');
        return res.redirect('/auth/register');
      }
      if (password !== confirm_password) {
        req.flash('error', 'Mật khẩu nhập lại không khớp.');
        return res.redirect('/auth/register');
      }
      if (!isValidPassword(password)) {
        req.flash('error', 'Mật khẩu phải có ít nhất 8 ký tự.');
        return res.redirect('/auth/register');
      }

      const [existingEmail, existingPhone] = await Promise.all([
        UserModel.findByEmail(email),
        UserModel.findByPhone(phone),
      ]);
      if (existingEmail || existingPhone) {
        req.flash('error', existingEmail ? 'Email này đã được đăng ký.' : 'Số điện thoại này đã được sử dụng.');
        return res.redirect('/auth/register');
      }

      const password_hash = await bcrypt.hash(password, 10);
      await UserModel.create({ full_name, email, password_hash, phone, address });

      req.flash('success', 'Đăng ký thành công! Vui lòng đăng nhập.');
      res.redirect('/auth/login');
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'Email hoặc số điện thoại đã được sử dụng.');
        return res.redirect('/auth/register');
      }
      next(err);
    }
  },

  // ---------- Xử lý đăng nhập ----------
  async login(req, res, next) {
    try {
      const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
      const password = typeof req.body.password === 'string' ? req.body.password : '';
      if (!email || !password) {
        req.flash('error', 'Vui lòng nhập email và mật khẩu.');
        return res.redirect('/auth/login');
      }
      const user = await UserModel.findByEmail(email);

      if (!user) {
        req.flash('error', 'Email hoặc mật khẩu không đúng.');
        return res.redirect('/auth/login');
      }

      const match = await bcrypt.compare(password, user.password_hash);
      if (!match) {
        req.flash('error', 'Email hoặc mật khẩu không đúng.');
        return res.redirect('/auth/login');
      }

      const returnTo = getLocalReturnPath(req.session.returnTo);
      const buyNow = req.session.buyNow;
      await new Promise((resolve, reject) => {
        req.session.regenerate((error) => error ? reject(error) : resolve());
      });

      req.session.user = {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      };
      req.session.cookie.maxAge = req.body.remember
        ? 1000 * 60 * 60 * 24 * 30
        : 1000 * 60 * 60 * 24;
      if (buyNow) req.session.buyNow = buyNow;

      req.flash('success', `Chào mừng trở lại, ${user.full_name}!`);
      if (returnTo === '/orders/checkout') return res.redirect(returnTo);
      if (user.role === 'admin') {
        return res.redirect('/admin');
      }
      if (returnTo) return res.redirect(returnTo);
      res.redirect('/');
    } catch (err) {
      next(err);
    }
  },

  // ---------- Đăng xuất ----------
  logout(req, res, next) {
    req.session.destroy((error) => {
      if (error) return next(error);
      res.redirect('/');
    });
  },
};

module.exports = authController;
