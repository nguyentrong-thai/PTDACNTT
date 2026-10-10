// Yêu cầu đã đăng nhập
function requireLogin(req, res, next) {
  if (!req.session.user) {
    req.flash('error', 'Vui lòng đăng nhập để tiếp tục.');
    return res.redirect('/auth/login');
  }
  next();
}

function requireStaff(req, res, next) {
  if (!req.session.user) {
    req.flash('error', 'Vui lòng đăng nhập để tiếp tục.');
    return res.redirect('/auth/login');
  }
  if (!['admin', 'employee'].includes(req.session.user.role)) {
    req.flash('error', 'Bạn không có quyền truy cập trang này.');
    return res.redirect('/');
  }
  next();
}

// Yêu cầu quyền admin (phải dùng SAU requireLogin, hoặc tự kiểm tra session)
function requireAdmin(req, res, next) {
  if (!req.session.user) {
    req.flash('error', 'Vui lòng đăng nhập để tiếp tục.');
    return res.redirect('/auth/login');
  }
  if (req.session.user.role !== 'admin') {
    req.flash('error', 'Bạn không có quyền truy cập trang này.');
    return res.redirect('/');
  }
  next();
}

module.exports = { requireLogin, requireStaff, requireAdmin };
