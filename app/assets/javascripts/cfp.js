document.addEventListener('change', (event) => {
  const input = event.target.closest('[data-photo-preview-input]');
  if (!input) {
    return;
  }

  const file = input.files[0];
  const image = input.closest('[data-photo-preview]').querySelector('[data-photo-preview-image]');

  if (!file || !file.type.startsWith('image/')) {
    return;
  }

  if (image.dataset.objectUrl) {
    URL.revokeObjectURL(image.dataset.objectUrl);
  }

  image.dataset.objectUrl = URL.createObjectURL(file);
  image.src = image.dataset.objectUrl;
});
