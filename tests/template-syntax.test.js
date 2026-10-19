const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');
const ejs = require('ejs');

function findTemplates(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    return entry.isDirectory()
      ? findTemplates(entryPath)
      : entry.name.endsWith('.ejs') ? [entryPath] : [];
  });
}

test('all EJS templates compile', () => {
  const viewsDirectory = path.join(__dirname, '..', 'views');
  for (const filename of findTemplates(viewsDirectory)) {
    assert.doesNotThrow(() => {
      ejs.compile(fs.readFileSync(filename, 'utf8'), { filename });
    }, `Invalid EJS template: ${path.relative(viewsDirectory, filename)}`);
  }
});
