const UserModel = require('../models/userModel');

// Yêu cầu đã đăng nhập
function requireLogin(req, res, next) {
  if (!req.session.user) {
    req.flash('error', 'Vui lòng đăng nhập để tiếp tục.');
    return res.redirect('/auth/login');
  }
  next();
}

function redirectAfterDestroyingSession(req, res, next) {
  req.session.destroy((error) => {
    if (error) return next(error);
    res.clearCookie('connect.sid');
    res.redirect('/auth/login');
  });
}

async function requireStaff(req, res, next) {
  if (!req.session.user) {
    req.flash('error', 'Vui lòng đăng nhập để tiếp tục.');
    return res.redirect('/auth/login');
  }

  try {
    const user = await UserModel.findById(req.session.user.id);
    if (!user) return redirectAfterDestroyingSession(req, res, next);

    req.currentUser = user;
    req.session.user.role = user.role;
    if (!['admin', 'employee'].includes(user.role)) {
      req.flash('error', 'Bạn không có quyền truy cập trang này.');
      return res.redirect('/');
    }
    next();
  } catch (error) {
    next(error);
  }
}

// Yêu cầu quyền admin (phải dùng SAU requireLogin, hoặc tự kiểm tra session)
async function requireAdmin(req, res, next) {
  if (!req.session.user) {
    req.flash('error', 'Vui lòng đăng nhập để tiếp tục.');
    return res.redirect('/auth/login');
  }

  try {
    const user = req.currentUser || await UserModel.findById(req.session.user.id);
    if (!user) return redirectAfterDestroyingSession(req, res, next);

    req.currentUser = user;
    req.session.user.role = user.role;
    if (user.role !== 'admin') {
      req.flash('error', 'Bạn không có quyền truy cập trang này.');
      return res.redirect('/');
    }
    next();
  } catch (error) {
    next(error);
  }
}

module.exports = { requireLogin, requireStaff, requireAdmin };
