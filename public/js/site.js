const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
const applyImageFallback = (image) => {
  if (!(image instanceof HTMLImageElement) || image.dataset.fallbackApplied) return;
  image.dataset.fallbackApplied = 'true';
  image.src = '/images/no-image.svg';
};

document.addEventListener('error', (event) => applyImageFallback(event.target), true);
document.querySelectorAll('img').forEach((image) => {
  if (image.complete && image.naturalWidth === 0) applyImageFallback(image);
});

document.querySelectorAll('form[method="post"], form[method="POST"]').forEach((form) => {
  if (csrfToken && !form.elements._csrf) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = '_csrf';
    input.value = csrfToken;
    form.prepend(input);
  }
});

document.querySelectorAll('form[data-auto-submit]').forEach((form) => {
  form.addEventListener('change', (event) => {
    if (event.target instanceof HTMLSelectElement) form.requestSubmit();
  });
});

document.querySelectorAll('[data-confirm-logout]').forEach((button) => {
  button.addEventListener('click', (event) => {
    if (!window.confirm('Bạn có chắc chắn muốn đăng xuất không?')) {
      event.preventDefault();
    }
  });
});

const searchForm = document.querySelector('.market-search');
const searchInput = document.querySelector('#site-search');
const searchDropdown = document.querySelector('#site-search-dropdown');
const searchSuggestions = document.querySelector('#site-search-suggestions');
const searchStatus = document.querySelector('#site-search-status');
const searchAllLink = document.querySelector('#site-search-all');

if (searchForm && searchInput && searchDropdown && searchSuggestions && searchStatus && searchAllLink) {
  let debounceTimer;
  let activeRequest;
  let activeSuggestionIndex = -1;

  const closeSuggestions = () => {
    searchDropdown.hidden = true;
    searchInput.setAttribute('aria-expanded', 'false');
    searchInput.removeAttribute('aria-activedescendant');
    activeSuggestionIndex = -1;
  };

  const setActiveSuggestion = (index) => {
    const options = searchSuggestions.querySelectorAll('[role="option"]');
    if (!options.length) return;

    activeSuggestionIndex = (index + options.length) % options.length;
    options.forEach((option, optionIndex) => {
      const isActive = optionIndex === activeSuggestionIndex;
      option.setAttribute('aria-selected', String(isActive));
      if (isActive) {
        searchInput.setAttribute('aria-activedescendant', option.id);
        option.scrollIntoView({ block: 'nearest' });
      }
    });
  };

  const showStatus = (message) => {
    searchSuggestions.replaceChildren();
    searchStatus.textContent = message;
    searchStatus.hidden = false;
    searchAllLink.hidden = false;
    searchDropdown.hidden = false;
    searchInput.setAttribute('aria-expanded', 'true');
    activeSuggestionIndex = -1;
  };

  const renderSuggestions = (products, query) => {
    searchSuggestions.replaceChildren();
    searchStatus.hidden = true;
    searchAllLink.href = `/products?${new URLSearchParams({ search: query }).toString()}`;
    searchAllLink.hidden = false;

    products.forEach((product, index) => {
      const option = document.createElement('li');
      option.className = 'market-search-suggestion';
      option.id = `site-search-option-${index}`;
      option.setAttribute('role', 'option');
      option.setAttribute('aria-selected', 'false');

      const image = document.createElement('img');
      image.src = product.image_url || '/images/no-image.svg';
      image.alt = '';
      image.loading = 'lazy';
      option.append(image);

      const details = document.createElement('span');
      details.className = 'market-search-suggestion-details';
      const name = document.createElement('strong');
      name.textContent = product.name;
      const brand = document.createElement('small');
      brand.textContent = product.brand || 'Thiết bị điện tử';
      details.append(name, brand);
      option.append(details);

      const price = document.createElement('strong');
      price.className = 'market-search-suggestion-price';
      price.textContent = `${Number(product.price).toLocaleString('vi-VN')} đ`;
      option.append(price);
      option.dataset.href = `/products/${encodeURIComponent(product.id)}`;
      searchSuggestions.append(option);
    });

    if (!products.length) {
      searchStatus.textContent = 'Chưa tìm thấy sản phẩm phù hợp.';
      searchStatus.hidden = false;
    }

    searchDropdown.hidden = false;
    searchInput.setAttribute('aria-expanded', 'true');
    activeSuggestionIndex = -1;
  };

  searchInput.addEventListener('input', () => {
    window.clearTimeout(debounceTimer);
    if (activeRequest) activeRequest.abort();
    closeSuggestions();

    const query = searchInput.value.trim();
    if (query.length < 2) return;
    searchAllLink.href = `/products?${new URLSearchParams({ search: query }).toString()}`;

    debounceTimer = window.setTimeout(async () => {
      activeRequest = new AbortController();
      try {
        const response = await fetch(`/products/suggestions?${new URLSearchParams({ search: query }).toString()}`, {
          headers: { Accept: 'application/json' },
          signal: activeRequest.signal,
        });
        if (!response.ok) throw new Error(`Tải gợi ý thất bại (${response.status}).`);
        renderSuggestions(await response.json(), query);
      } catch (error) {
        if (error.name !== 'AbortError') {
          showStatus('Không thể tải gợi ý. Nhấn Enter để tìm kiếm.');
        }
      }
    }, 250);
  });

  searchInput.addEventListener('keydown', (event) => {
    const options = searchSuggestions.querySelectorAll('[role="option"]');
    if (event.key === 'ArrowDown' && options.length) {
      event.preventDefault();
      setActiveSuggestion(activeSuggestionIndex + 1);
    } else if (event.key === 'ArrowUp' && options.length) {
      event.preventDefault();
      setActiveSuggestion(activeSuggestionIndex < 0 ? options.length - 1 : activeSuggestionIndex - 1);
    } else if (event.key === 'Enter' && activeSuggestionIndex >= 0) {
      event.preventDefault();
      window.location.assign(options[activeSuggestionIndex].dataset.href);
    } else if (event.key === 'Escape') {
      closeSuggestions();
    }
  });

  searchSuggestions.addEventListener('pointerover', (event) => {
    const option = event.target.closest('[role="option"]');
    if (option) setActiveSuggestion(Array.from(searchSuggestions.children).indexOf(option));
  });

  searchSuggestions.addEventListener('click', (event) => {
    const option = event.target.closest('[role="option"]');
    if (option?.dataset.href) window.location.assign(option.dataset.href);
  });

  document.addEventListener('pointerdown', (event) => {
    if (!searchForm.contains(event.target)) closeSuggestions();
  });

  searchForm.addEventListener('submit', () => {
    if (activeRequest) activeRequest.abort();
  });
}