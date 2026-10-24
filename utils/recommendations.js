function normalize(value) {
  return value
    .toLocaleLowerCase('vi')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd');
}

function parseBudgetConstraint(message) {
  const match = message.match(
    /(?:\b(duoi|under|toi da|max|tren|above|over)\s*|(<|>=)\s*)(\d+(?:[.,]\d+)*)(?:\s*(trieu|tr|m|million|k))?|(\d+(?:[.,]\d+)*)\s*(trieu|tr|m|million|k)\b|(\d{1,3}(?:[.,]\d{3})+|\d{5,})/i
  );
  if (!match) return null;

  const rawAmount = match[3] || match[5] || match[7];
  const unit = (match[4] || match[6] || '').toLowerCase();
  const amount = unit
    ? Number(rawAmount.replace(',', '.'))
    : Number(rawAmount.replace(/[.,]/g, ''));
  if (!Number.isFinite(amount)) return null;

  let multiplier = 1;
  if (['trieu', 'tr', 'm', 'million'].includes(unit)) multiplier = 1000000;
  if (unit === 'k') multiplier = 1000;

  return {
    amount: amount * multiplier,
    direction: ['tren', 'above', 'over'].includes(match[1]) || match[2] === '>='
      ? 'minimum'
      : 'maximum',
  };
}

function parseBudget(message) {
  return parseBudgetConstraint(message)?.amount ?? null;
}

function findRecommendations(products, message) {
  const normalizedMessage = normalize(message);
  const budgetConstraint = parseBudgetConstraint(normalizedMessage);
  const ignoredWords = new Set([
    'toi', 'can', 'muon', 'tim', 'tu', 'van', 'gia', 'duoi', 'tren', 'khoang',
    'cho', 'mot', 'con', 'hang', 'nao', 'loai', 'san', 'pham', 'goi', 'y',
    'giup', 'voi', 'va', 'co', 'khong', 'la', 'the', 'ngan', 'sach', 'mua',
    'trieu', 'tr', 'm', 'k', 'million', 'under', 'max', 'above', 'over',
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
    .filter((product) => {
      if (!budgetConstraint) return true;
      const price = Number(product.price);
      return budgetConstraint.direction === 'minimum'
        ? price >= budgetConstraint.amount
        : price <= budgetConstraint.amount;
    })
    .map((product) => {
      const searchable = normalize(`${product.name} ${product.brand || ''} ${product.category_name}`);
      const score = keywords.reduce((total, word) => total + (searchable.includes(word) ? 1 : 0), 0);
      const categoryMatch = requestedCategory
        && normalize(product.category_name).includes(requestedCategory[0].replace(/-/g, ' '));
      return { product, score: score + (categoryMatch ? 3 : 0) };
    })
    .filter(({ score }) => !hasProductIntent || score > 0)
    .sort((left, right) => {
      if (right.score !== left.score) return right.score - left.score;
      if (!budgetConstraint) return Number(left.product.price) - Number(right.product.price);
      return budgetConstraint.direction === 'minimum'
        ? Number(left.product.price) - Number(right.product.price)
        : Number(right.product.price) - Number(left.product.price);
    })
    .slice(0, 3)
    .map(({ product }) => product);
}

module.exports = { findRecommendations, normalize, parseBudget };
