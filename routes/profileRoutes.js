const express = require('express');
const bcrypt = require('bcrypt');
const UserModel = require('../models/userModel');
const { requireLogin } = require('../middlewares/authMiddleware');

const router = express.Router();
router.use(requireLogin);

function getProfileInput(body = {}) {
  const fullName = typeof body.full_name === 'string' ? body.full_name.trim() : '';
  const phone = typeof body.phone === 'string' ? body.phone.trim() : '';
  const address = typeof body.address === 'string' ? body.address.trim() : '';
  const gender = typeof body.gender === 'string' ? body.gender : '';
  const dateOfBirth = typeof body.date_of_birth === 'string' ? body.date_of_birth : '';

  if (!fullName || fullName.length > 100 || phone.length > 20 || address.length > 255) return null;
  if (gender && !['male', 'female', 'other'].includes(gender)) return null;
  if (dateOfBirth && !/^\d{4}-\d{2}-\d{2}$/.test(dateOfBirth)) return null;
  return { full_name: fullName, phone, address, gender, date_of_birth: dateOfBirth };
}

router.get('/', async (req, res, next) => {
  try {
    const user = await UserModel.findById(req.session.user.id);
    if (!user) return res.status(404).render('404', { title: 'Không tìm thấy tài khoản' });
    res.render('profile/index', { title: 'Thông tin cá nhân', user });
  } catch (err) { next(err); }
});

router.post('/password', async (req, res, next) => {
  try {
    const currentPassword = typeof req.body.current_password === 'string' ? req.body.current_password : '';
    const newPassword = typeof req.body.new_password === 'string' ? req.body.new_password : '';
    const confirmPassword = typeof req.body.confirm_password === 'string' ? req.body.confirm_password : '';

    if (!currentPassword || !newPassword || !confirmPassword) {
      req.flash('error', 'Vui lòng nhập đầy đủ các trường mật khẩu.');
      return res.redirect('/profile');
    }
    if (newPassword.length < 6) {
      req.flash('error', 'Mật khẩu mới phải có ít nhất 6 ký tự.');
      return res.redirect('/profile');
    }
    if (newPassword !== confirmPassword) {
      req.flash('error', 'Mật khẩu mới nhập lại không khớp.');
      return res.redirect('/profile');
    }

    const account = await UserModel.findAuthById(req.session.user.id);
    if (!account) return res.status(404).render('404', { title: 'Không tìm thấy tài khoản' });
    if (!await bcrypt.compare(currentPassword, account.password_hash)) {
      req.flash('error', 'Mật khẩu hiện tại không chính xác.');
      return res.redirect('/profile');
    }

    const password_hash = await bcrypt.hash(newPassword, 10);
    const passwordUpdated = await UserModel.updatePassword(req.session.user.id, password_hash);
    if (!passwordUpdated) {
      throw new Error(`Password update affected no user row (user id: ${req.session.user.id}).`);
    }
    const updatedAccount = await UserModel.findAuthById(req.session.user.id);
    if (!updatedAccount || !await bcrypt.compare(newPassword, updatedAccount.password_hash)) {
      throw new Error(`Password update could not be verified in the database (user id: ${req.session.user.id}).`);
    }
    req.flash('success', 'Đã đổi mật khẩu thành công.');
    return res.redirect('/profile');
  } catch (err) { next(err); }
});

router.post('/', async (req, res, next) => {
  try {
    const profile = getProfileInput(req.body);
    if (!profile) {
      req.flash('error', 'Vui lòng kiểm tra lại thông tin cá nhân.');
      return res.redirect('/profile');
    }
    await UserModel.updateProfile(req.session.user.id, profile);
    req.session.user.full_name = profile.full_name;
    req.flash('success', 'Đã cập nhật thông tin cá nhân.');
    res.redirect('/profile');
  } catch (err) { next(err); }
});

module.exports = router;
