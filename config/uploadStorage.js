const fs = require('fs');
const path = require('path');

const configuredDirectory = process.env.UPLOAD_DIR || path.join('public', 'images', 'products');
const uploadDirectory = path.isAbsolute(configuredDirectory)
  ? configuredDirectory
  : path.resolve(__dirname, '..', configuredDirectory);

fs.mkdirSync(uploadDirectory, { recursive: true });

module.exports = uploadDirectory;
