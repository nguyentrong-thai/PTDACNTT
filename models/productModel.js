const { pool } = require('../config/db');

const searchableColumns = ['p.name', 'p.brand', 'p.description'];

function getSearchTerms(search) {
  const normalizedSearch = typeof search === 'string' ? search.trim().replace(/\s+/g, ' ') : '';
  return normalizedSearch ? normalizedSearch.toLowerCase().split(' ') : [];
}

function buildSearchConditions(searchTerms) {
  const conditions = [];
  const values = [];
  for (const term of searchTerms) {
    conditions.push(`(${searchableColumns
      .map((column) => `LOWER(${column}) COLLATE utf8mb4_unicode_ci LIKE ?`)
      .join(' OR ')})`);
    values.push(...searchableColumns.map(() => `%${term}%`));
  }
  return { conditions, values };
}

const ProductModel = {
  async findAll({ search = '', category = '', brand = '', page = 1, limit = 12 } = {}) {
    const conditions = ['p.is_active = 1'];
    const normalizedSearch = typeof search === 'string' ? search.trim().replace(/\s+/g, ' ') : '';
    const { conditions: searchConditions, values } = buildSearchConditions(getSearchTerms(normalizedSearch));
    conditions.push(...searchConditions);
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
      ? [
        normalizedSearch.toLowerCase(),
        `${normalizedSearch.toLowerCase()}%`,
        `%${normalizedSearch.toLowerCase()}%`,
        `%${normalizedSearch.toLowerCase()}%`,
      ]
      : [];
    const orderBy = normalizedSearch
      ? `CASE
           WHEN LOWER(p.name) COLLATE utf8mb4_unicode_ci = ? THEN 0
           WHEN LOWER(p.name) COLLATE utf8mb4_unicode_ci LIKE ? THEN 1
           WHEN LOWER(p.name) COLLATE utf8mb4_unicode_ci LIKE ? THEN 2
           WHEN LOWER(p.brand) COLLATE utf8mb4_unicode_ci LIKE ? THEN 3
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
  async findSuggestions(search, limit = 6) {
    const searchTerms = getSearchTerms(search);
    if (!searchTerms.length) return [];

    const { conditions, values } = buildSearchConditions(searchTerms);
    const normalizedSearch = search.trim().replace(/\s+/g, ' ').toLowerCase();
    const suggestionLimit = Math.min(Math.max(Number.parseInt(limit, 10) || 6, 1), 10);
    const [rows] = await pool.query(
      `SELECT p.id, p.name, p.brand, p.price, p.image_url
       FROM products p
       WHERE p.is_active = 1 AND ${conditions.join(' AND ')}
       ORDER BY CASE
         WHEN LOWER(p.name) COLLATE utf8mb4_unicode_ci = ? THEN 0
         WHEN LOWER(p.name) COLLATE utf8mb4_unicode_ci LIKE ? THEN 1
         WHEN LOWER(p.name) COLLATE utf8mb4_unicode_ci LIKE ? THEN 2
         ELSE 3
       END, p.created_at DESC, p.id DESC
       LIMIT ?`,
      [
        ...values,
        normalizedSearch,
        `${normalizedSearch}%`,
        `%${normalizedSearch}%`,
        suggestionLimit,
      ]
    );
    return rows;
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