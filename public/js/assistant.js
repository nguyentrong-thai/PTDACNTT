document.querySelectorAll('[data-assistant-widget]').forEach((widget) => {
  const toggle = widget.querySelector('[data-assistant-toggle]');
  const close = widget.querySelector('[data-assistant-close]');
  const panel = widget.querySelector('[data-assistant-panel]');
  const form = widget.querySelector('[data-assistant-form]');
  const messages = widget.querySelector('[data-assistant-messages]');

  function setOpen(open) {
    panel.hidden = !open;
    toggle.setAttribute('aria-expanded', String(open));
    if (open) form.elements.message.focus();
  }

  function addMessage(text, kind) {
    const message = document.createElement('p');
    message.className = `assistant-message assistant-message--${kind}`;
    message.textContent = text;
    messages.append(message);
    messages.scrollTop = messages.scrollHeight;
  }

  function addRecommendations(products) {
    if (!products.length) return;
    const list = document.createElement('div');
    list.className = 'assistant-recommendations';
    products.forEach((product) => {
      const link = document.createElement('a');
      link.href = `/products/${encodeURIComponent(product.id)}`;
      link.className = 'assistant-recommendation';
      link.textContent = `${product.name} · ${Number(product.price).toLocaleString('vi-VN')} đ`;
      list.append(link);
    });
    messages.append(list);
    messages.scrollTop = messages.scrollHeight;
  }

  toggle.addEventListener('click', () => setOpen(panel.hidden));
  close.addEventListener('click', () => setOpen(false));
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const input = form.elements.message;
    const question = input.value.trim();
    if (!question) return;
    addMessage(question, 'user');
    input.value = '';

    const submitButton = form.querySelector('button');
    submitButton.disabled = true;
    try {
      const response = await fetch('/assistant', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        },
        body: JSON.stringify({ message: question, _csrf: document.querySelector('meta[name="csrf-token"]').content }),
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.reply || 'Không thể lấy gợi ý lúc này.');
      addMessage(result.reply, 'bot');
      addRecommendations(result.products);
    } catch (error) {
      addMessage(error.message || 'Đã có lỗi khi kết nối. Vui lòng thử lại.', 'bot');
    } finally {
      submitButton.disabled = false;
      input.focus();
    }
  });
});