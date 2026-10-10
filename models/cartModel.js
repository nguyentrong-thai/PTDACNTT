const { pool } = require('../config/db');

const CartModel = {
  async findByUser(userId) {
    const [rows] = await pool.query(
      `SELECT p.id, p.name, p.price, p.image_url, p.stock_qty, p.is_active, ci.quantity
       FROM cart_items ci
       JOIN products p ON p.id = ci.product_id
       WHERE ci.user_id = ?
       ORDER BY ci.added_at DESC`,
      [userId]
    );
    return rows.map((row) => ({ ...row, price: Number(row.price) }));
  },

  async countQuantity(userId) {
    const [[row]] = await pool.query(
      'SELECT COALESCE(SUM(quantity), 0) AS quantity FROM cart_items WHERE user_id = ?',
      [userId]
    );
    return Number(row.quantity);
  },

  async add(userId, productId, quantity) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      await connection.query('SELECT id FROM users WHERE id = ? FOR UPDATE', [userId]);
      const [[product]] = await connection.query(
        'SELECT id, stock_qty FROM products WHERE id = ? AND is_active = 1 FOR UPDATE',
        [productId]
      );
      if (!product || product.stock_qty < 1) {
        await connection.rollback();
        return false;
      }

      const [[item]] = await connection.query(
        'SELECT quantity FROM cart_items WHERE user_id = ? AND product_id = ? FOR UPDATE',
        [userId, productId]
      );
      const nextQuantity = Math.min((item ? item.quantity : 0) + quantity, product.stock_qty);
      if (item) {
        await connection.query(
          'UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_id = ?',
          [nextQuantity, userId, productId]
        );
      } else {
        await connection.query(
          'INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)',
          [userId, productId, nextQuantity]
        );
      }
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  },

  async updateQuantity(userId, productId, quantity) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      await connection.query('SELECT id FROM users WHERE id = ? FOR UPDATE', [userId]);
      const [[product]] = await connection.query(
        `SELECT p.stock_qty, p.is_active
         FROM products p
         JOIN cart_items ci ON ci.product_id = p.id
         WHERE p.id = ? AND ci.user_id = ? FOR UPDATE`,
        [productId, userId]
      );
      if (!product) {
        await connection.rollback();
        return false;
      }
      if (!product.is_active || product.stock_qty < 1) {
        await connection.query(
          'DELETE FROM cart_items WHERE user_id = ? AND product_id = ?',
          [userId, productId]
        );
        await connection.commit();
        return false;
      }
      await connection.query(
        'UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_id = ?',
        [Math.min(quantity, product.stock_qty), userId, productId]
      );
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  },

  async remove(userId, productId) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      await connection.query('SELECT id FROM users WHERE id = ? FOR UPDATE', [userId]);
      await connection.query('DELETE FROM cart_items WHERE user_id = ? AND product_id = ?', [userId, productId]);
      await connection.commit();
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  },

  async clear(userId, connection = pool) {
    await connection.query('DELETE FROM cart_items WHERE user_id = ?', [userId]);
  },

  async findForCheckout(userId, connection = pool) {
    await connection.query('SELECT id FROM users WHERE id = ? FOR UPDATE', [userId]);
    const [rows] = await connection.query(
      `SELECT ci.product_id AS id, ci.quantity, p.name
       FROM cart_items ci
       JOIN products p ON p.id = ci.product_id
      WHERE ci.user_id = ?
      ORDER BY ci.product_id FOR UPDATE`,
      [userId]
    );
    return rows;
  },
};

module.exports = CartModel;