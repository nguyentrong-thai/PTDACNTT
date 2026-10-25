const path = require('path');
const multer = require('multer');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, callback) => {
    const extension = path.extname(file.originalname).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.webp'].includes(extension) && ['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) return callback(null, true);
    callback(new Error('Chỉ được upload file hình ảnh.'));
  },
});

function productImageUpload(req, res, next) {
  const match = req.method === 'POST' && req.path.match(/^\/admin\/products(?:\/([1-9]\d*)\/update)?$/);
  if (!match || !req.is('multipart/form-data')) return next();

  upload.single('image')(req, res, (error) => {
    if (!error) return next();
    req.flash('error', error.code === 'LIMIT_FILE_SIZE'
      ? 'Ảnh sản phẩm không được vượt quá 5 MB.'
      : 'Chỉ chấp nhận ảnh JPG, PNG hoặc WebP.');
    res.redirect(match[1] ? `/admin/products/${match[1]}/edit` : '/admin/products/new');
  });
}

module.exports = productImageUpload;
