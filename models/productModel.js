const { pool } = require('../config/db');

const ProductModel = {
  async findAll({ search = '', category = '', brand = '', page = 1, limit = 12 } = {}) {
    const conditions = ['p.is_active = 1'];
    const values = [];
    const normalizedSearch = typeof search === 'string' ? search.trim().replace(/\s+/g, ' ') : '';
    const searchTerms = normalizedSearch ? normalizedSearch.split(' ') : [];
    for (const term of searchTerms) {
      conditions.push('(p.name LIKE ? OR p.brand LIKE ? OR p.description LIKE ?)');
      values.push(`%${term}%`, `%${term}%`, `%${term}%`);
    }
    if (category) { conditions.push('c.slug = ?'); values.push(category); }
    if (brand) { conditions.push('p.brand = ?'); values.push(brand); }
    const [countRows] = await pool.query(
      `SELECT COUNT(*) AS total
       FROM products p JOIN categories c ON c.id = p.category_id
       WHERE ${conditions.join(' AND ')}`, values
    );
    const total = Number(countRows[0].total);
    const totalPages = Math.max(1, Math.ceil(total / limit));
    const currentPage = Math.min(page, totalPages);
    const orderValues = normalizedSearch
      ? [normalizedSearch, `${normalizedSearch}%`, `%${normalizedSearch}%`, `%${normalizedSearch}%`]
      : [];
    const orderBy = normalizedSearch
      ? `CASE
           WHEN p.name = ? THEN 0
           WHEN p.name LIKE ? THEN 1
           WHEN p.name LIKE ? THEN 2
           WHEN p.brand LIKE ? THEN 3
           ELSE 4
         END, p.created_at DESC, p.id DESC`
      : 'p.created_at DESC, p.id DESC';
    const [rows] = await pool.query(
      `SELECT p.*, c.name AS category_name, c.slug AS category_slug
       FROM products p JOIN categories c ON c.id = p.category_id
       WHERE ${conditions.join(' AND ')} ORDER BY ${orderBy} LIMIT ? OFFSET ?`,
      [...values, ...orderValues, limit, (currentPage - 1) * limit]
    );
    return { rows, total, currentPage };
  },
  async findById(id) {
    const [rows] = await pool.query(
      `SELECT p.*, c.name AS category_name, c.slug AS category_slug
       FROM products p JOIN categories c ON c.id = p.category_id
       WHERE p.id = ? AND p.is_active = 1`, [id]
    );
    return rows[0] || null;
  },
  async getCategories() { const [rows] = await pool.query('SELECT id, name, slug FROM categories ORDER BY name'); return rows; },
  async getBrands() {
    const [rows] = await pool.query('SELECT DISTINCT brand FROM products WHERE is_active = 1 AND brand IS NOT NULL ORDER BY brand');
    return rows.map((row) => row.brand);
  },
};

module.exports = ProductModel;