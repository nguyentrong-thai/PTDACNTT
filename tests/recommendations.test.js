const test = require('node:test');
const assert = require('node:assert/strict');
const { findRecommendations, normalize, parseBudget } = require('../utils/recommendations');

const products = [
  { id: 1, name: 'Laptop Gaming Alpha', brand: 'Acer', category_name: 'Laptop', price: 18000000 },
  { id: 2, name: 'Laptop Gaming Beta', brand: 'Asus', category_name: 'Laptop', price: 25000000 },
  { id: 3, name: 'Tai nghe không dây', brand: 'Sony', category_name: 'Phụ kiện', price: 2000000 },
];

test('recommendations understand Vietnamese category keywords and budgets', () => {
  const results = findRecommendations(products, 'laptop gaming dưới 20 triệu');
  assert.deepEqual(results.map((product) => product.id), [1]);
  assert.equal(parseBudget(normalize('dưới 10,5 triệu')), 10500000);
});

test('recommendations do not return unrelated products for an unmatched keyword', () => {
  assert.deepEqual(findRecommendations(products, 'máy ảnh chuyên dụng'), []);
});

test('budget-only requests recommend affordable products', () => {
  assert.deepEqual(
    findRecommendations(products, 'dưới 10 triệu').map((product) => product.id),
    [3]
  );
});

test('recommendations are limited to three results', () => {
  const manyProducts = Array.from({ length: 6 }, (_, index) => ({
    id: index + 1,
    name: `Laptop ${index + 1}`,
    category_name: 'Laptop',
    price: 1000000 + index,
  }));
  assert.equal(findRecommendations(manyProducts, 'laptop').length, 3);
});
