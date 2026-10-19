function normalize(value) {
  return value
    .toLocaleLowerCase('vi')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd');
}

function parseBudget(message) {
  const match = message.match(/(?:duoi|under|toi da|max|<)\s*(\d+(?:[.,]\d+)?)\s*(trieu|tr|m|million|k)?/i);
  if (!match) return null;
  const amount = Number(match[1].replace(',', '.'));
  const unit = (match[2] || '').toLowerCase();
  if (['trieu', 'tr', 'm', 'million'].includes(unit)) return amount * 1000000;
  if (unit === 'k') return amount * 1000;
  return amount;
}

function findRecommendations(products, message) {
  const normalizedMessage = normalize(message);
  const budget = parseBudget(normalizedMessage);
  const ignoredWords = new Set([
    'toi', 'can', 'muon', 'tim', 'tu', 'van', 'gia', 'duoi', 'tren', 'khoang',
    'cho', 'mot', 'con', 'hang', 'nao', 'loai', 'san', 'pham', 'goi', 'y',
    'giup', 'voi', 'va', 'co', 'khong', 'la', 'the', 'ngan', 'sach', 'mua',
    'trieu', 'million', 'under', 'max',
  ]);
  const keywords = normalizedMessage.split(/[^a-z0-9]+/)
    .filter((word) => word.length > 1 && !ignoredWords.has(word) && !/^\d/.test(word));
  const categoryTerms = {
    'dien-thoai': ['dien thoai', 'smartphone', 'iphone', 'samsung', 'oppo'],
    laptop: ['laptop', 'may tinh xach tay', 'gaming'],
    'phu-kien': ['phu kien', 'tai nghe', 'chuot', 'ban phim', 'sac'],
    'dong-ho-thong-minh': ['dong ho', 'smartwatch', 'garmin', 'watch'],
  };
  const requestedCategory = Object.entries(categoryTerms)
    .find(([, terms]) => terms.some((term) => normalizedMessage.includes(term)));
  const hasProductIntent = keywords.length > 0 || Boolean(requestedCategory);

  return products
    .filter((product) => !budget || Number(product.price) <= budget)
    .map((product) => {
      const searchable = normalize(`${product.name} ${product.brand || ''} ${product.category_name}`);
      const score = keywords.reduce((total, word) => total + (searchable.includes(word) ? 1 : 0), 0);
      const categoryMatch = requestedCategory
        && normalize(product.category_name).includes(requestedCategory[0].replace(/-/g, ' '));
      return { product, score: score + (categoryMatch ? 3 : 0) };
    })
    .filter(({ score }) => !hasProductIntent || score > 0)
    .sort((left, right) => right.score - left.score || Number(left.product.price) - Number(right.product.price))
    .slice(0, 3)
    .map(({ product }) => product);
}

module.exports = { findRecommendations, normalize, parseBudget };
