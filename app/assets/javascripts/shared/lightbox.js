ConferenceBox.Lightbox = class Lightbox {
  static TEMPLATE = `
    <div class="lightbox" role="dialog" aria-modal="true" aria-label="Photo">
      <button type="button" class="lb-button lb-close" aria-label="Close">✕</button>
      <div class="lb-container"></div>
      <div class="lb-cloak"></div>
      <div class="lb-controls">
        <button type="button" class="lb-button lb-previous" aria-label="Previous">←</button>
        <button type="button" class="lb-button lb-next" aria-label="Next">→</button>
      </div>
    </div>`;

  static SWIPE_THRESHOLD = 40;

  static start(container = document.body) {
    container.addEventListener('click', (event) => {
      const target = event.target.closest('[data-src]');
      if (!target) { return; }

      event.preventDefault();
      const items = Array.from(container.querySelectorAll('[data-src]'), (el) => el.dataset.src);
      new Lightbox(items, items.indexOf(target.dataset.src)).open();
    });
  }

  constructor(items, index = 0) {
    this.items = items;
    this.index = index;
    this.cache = new Map();
    this.element = ConferenceBox.html(Lightbox.TEMPLATE);
    this.container = this.element.querySelector('.lb-container');
    this.cloak = this.element.querySelector('.lb-cloak');
    this.onKey = (event) => this.handleKey(event);
    this.bind();
  }

  bind() {
    this.element.querySelector('.lb-close').addEventListener('click', () => this.close());
    this.element.querySelector('.lb-previous').addEventListener('click', () => this.show(this.index - 1));
    this.element.querySelector('.lb-next').addEventListener('click', () => this.show(this.index + 1));

    this.element.addEventListener('pointerdown', (event) => { this.pointerStart = event.clientX; });
    this.element.addEventListener('pointerup', (event) => {
      if (this.pointerStart === undefined) { return; }
      const delta = event.clientX - this.pointerStart;
      this.pointerStart = undefined;
      if (Math.abs(delta) < Lightbox.SWIPE_THRESHOLD) { return; }
      this.show(delta > 0 ? this.index - 1 : this.index + 1);
    });
  }

  open() {
    document.body.append(this.element);
    document.body.classList.add('lightbox-parent');
    window.addEventListener('keyup', this.onKey);
    this.element.querySelector('.lb-close').focus();
    this.show(this.index);
  }

  close() {
    window.removeEventListener('keyup', this.onKey);
    document.body.classList.remove('lightbox-parent');
    this.element.remove();
  }

  handleKey(event) {
    if (event.key === 'Escape') { this.close(); }
    if (event.key === 'ArrowLeft') { this.show(this.index - 1); }
    if (event.key === 'ArrowRight') { this.show(this.index + 1); }
  }

  show(index) {
    this.index = (index + this.items.length) % this.items.length;
    this.cloak.hidden = false;
    this.container.replaceChildren();

    this.load(this.items[this.index]).then((image) => {
      if (image.src !== this.items[this.index]) { return; }
      const element = new Image();
      element.src = image.src;
      element.alt = '';
      this.container.replaceChildren(element);
      this.cloak.hidden = true;
    });
  }

  load(src) {
    if (!this.cache.has(src)) {
      this.cache.set(src, new Promise((resolve) => {
        const image = new Image();
        image.onload = () => resolve(image);
        image.src = src;
      }));
    }
    return this.cache.get(src);
  }
};
