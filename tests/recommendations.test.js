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

test('a product category and budget without a comparator recommend products near the budget', () => {
  const results = findRecommendations(products, 'laptop 20 triệu');
  assert.deepEqual(results.map((product) => product.id), [1]);
});

test('budget recommendations prioritize products closest to the stated maximum', () => {
  const laptops = [
    { id: 1, name: 'Laptop Budget', category_name: 'Laptop', price: 30000000 },
    { id: 2, name: 'Laptop Premium', category_name: 'Laptop', price: 59000000 },
    { id: 3, name: 'Laptop Midrange', category_name: 'Laptop', price: 45000000 },
    { id: 4, name: 'Laptop Too Expensive', category_name: 'Laptop', price: 65000000 },
  ];
  assert.deepEqual(
    findRecommendations(laptops, 'laptop 60 triệu').map((product) => product.id),
    [2, 3, 1]
  );
});

test('budget amounts without a comparator are parsed as maximum budgets', () => {
  assert.equal(parseBudget(normalize('laptop 60 triệu')), 60000000);
  assert.equal(parseBudget(normalize('laptop 60.000.000')), 60000000);
});

test('recommendations honor minimum budget requests', () => {
  assert.deepEqual(
    findRecommendations(products, 'trên 10 triệu').map((product) => product.id),
    [1, 2]
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
