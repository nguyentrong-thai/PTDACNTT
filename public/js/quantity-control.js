document.querySelectorAll('[data-quantity-control]').forEach((control) => {
  const input = control.querySelector('input[type="number"]');
  const decreaseButton = control.querySelector('[data-step="-1"]');
  const increaseButton = control.querySelector('[data-step="1"]');
  if (!input || !decreaseButton || !increaseButton) return;

  const minimum = Number(input.min) || 1;
  const maximum = Number(input.max) || minimum;

  function updateButtons() {
    const quantity = Number(input.value) || minimum;
    decreaseButton.disabled = input.disabled || quantity <= minimum;
    increaseButton.disabled = input.disabled || quantity >= maximum;
  }

  control.addEventListener('click', (event) => {
    const button = event.target.closest('[data-step]');
    if (!button || button.disabled) return;

    const quantity = Number(input.value) || minimum;
    input.value = String(Math.min(maximum, Math.max(minimum, quantity + Number(button.dataset.step))));
    input.dispatchEvent(new Event('input', { bubbles: true }));
  });

  input.addEventListener('input', updateButtons);
  input.addEventListener('change', () => {
    const quantity = Number(input.value) || minimum;
    input.value = String(Math.min(maximum, Math.max(minimum, quantity)));
    updateButtons();
  });

  updateButtons();
});