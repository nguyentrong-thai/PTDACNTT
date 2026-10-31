const searchInput = document.querySelector('[data-user-search]');
const rows = [...document.querySelectorAll('[data-user-row]')];

searchInput?.addEventListener('input', () => {
  const query = searchInput.value.trim().toLowerCase();
  rows.forEach((row) => {
    row.hidden = query && !row.textContent.toLowerCase().includes(query);
  });
});
