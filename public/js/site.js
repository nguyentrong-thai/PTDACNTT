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