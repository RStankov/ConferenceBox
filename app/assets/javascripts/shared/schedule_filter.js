ConferenceBox.ScheduleFilter = class ScheduleFilter {
  static DEBOUNCE = 150;
  static STORAGE_KEY = 'cb-schedule-track';

  static start(root = document) {
    return Array.from(root.querySelectorAll('[data-schedule-filter]'), (element) => new ScheduleFilter(element));
  }

  #root;
  #input;
  #tabs;
  #track = 'all';
  #query = '';
  #debounceTimer;

  constructor(root) {
    this.#root = root;
    this.#track = ScheduleFilter.#restoreTrack();
    this.#render();
    this.#bind();
    this.apply();
  }

  apply() {
    let visible = 0;

    this.#cards().forEach((card) => {
      const matches = this.#matchesTrack(card) && this.#matchesQuery(card);
      card.hidden = !matches;
      if (matches) visible += 1;
    });

    this.#renderEmptyState(visible);
    this.#tabs.forEach((tab) => tab.setAttribute('aria-selected', String(tab.dataset.track === this.#track)));
  }

  selectTrack(track) {
    this.#track = track;
    ScheduleFilter.#storeTrack(track);
    this.apply();
  }

  _highlight(card) {
    const title = card.querySelector('strong');
    if (!this.#query) {
      title.innerHTML = title.textContent;
      return;
    }

    title.innerHTML = title.textContent.replace(new RegExp(`(${this.#query})`, 'gi'), '<mark>$1</mark>');
  }

  #render() {
    const tracks = [...new Set(this.#cards().map((card) => card.closest('[data-track]')?.dataset.track).filter(Boolean))];
    const toolbar = ConferenceBox.html('<div class="schedule-filter" role="toolbar"></div>');

    this.#input = ConferenceBox.html('<input type="search" class="schedule-filter__search" placeholder="Търси лекция или лектор">');
    toolbar.append(this.#input);

    if (tracks.length > 1) {
      this.#tabs = ['all', ...tracks].map((track) => {
        const label = track === 'all' ? 'Всички' : `Track ${track}`;
        const tab = ConferenceBox.html(`<button type="button" class="cb-badge" data-track="${track}">${label}</button>`);
        toolbar.append(tab);
        return tab;
      });
    } else {
      this.#tabs = [];
    }

    this.#root.prepend(toolbar);
  }

  #bind() {
    this.#input.addEventListener('input', () => {
      window.clearTimeout(this.#debounceTimer);
      this.#debounceTimer = window.setTimeout(() => {
        this.#query = this.#input.value.trim();
        this.#cards().forEach((card) => this._highlight(card));
        this.apply();
      }, ScheduleFilter.DEBOUNCE);
    });

    this.#tabs.forEach((tab) => {
      tab.addEventListener('click', () => this.selectTrack(tab.dataset.track));
    });
  }

  #cards() {
    return Array.from(this.#root.querySelectorAll('.schedule-card:not(.schedule-card--break)'));
  }

  #matchesTrack(card) {
    return this.#track === 'all' || card.closest('[data-track]')?.dataset.track === this.#track;
  }

  #matchesQuery(card) {
    if (!this.#query) return true;
    return card.textContent.toLowerCase().includes(this.#query.toLowerCase());
  }

  #renderEmptyState(visible) {
    let empty = this.#root.querySelector('.schedule-filter__empty');
    if (visible > 0) {
      empty?.remove();
      return;
    }

    if (!empty) {
      empty = ConferenceBox.html('<p class="schedule-filter__empty"></p>');
      this.#root.append(empty);
    }
    empty.innerHTML = `Няма резултати за „${this.#query}“`;
  }

  static #restoreTrack() {
    return window.localStorage.getItem(ScheduleFilter.STORAGE_KEY) || 'all';
  }

  static #storeTrack(track) {
    window.localStorage.setItem(ScheduleFilter.STORAGE_KEY, track);
  }
};
