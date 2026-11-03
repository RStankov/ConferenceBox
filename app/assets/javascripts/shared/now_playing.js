ConferenceBox.NowPlaying = class NowPlaying {
  static ACTIVE_CLASS = 'schedule-card--now';
  static PAST_CLASS = 'schedule-card--past';
  static #REFRESH_INTERVAL = 30 * 1000;

  static start(root = document) {
    const cards = root.querySelectorAll('[data-now-playing]');
    if (cards.length === 0) {
      return null;
    }

    return new NowPlaying(Array.from(cards));
  }

  #cards;
  #timer = null;
  #lastActive = [];

  constructor(cards) {
    this.#cards = cards.map((element) => ({
      element,
      startsAt: new Date(element.dataset.startsAt),
      endsAt: new Date(element.dataset.endsAt),
    }));

    this.refresh();
    this.#timer = window.setInterval(() => this.refresh(), NowPlaying.#REFRESH_INTERVAL);
    document.addEventListener('visibilitychange', this._onVisibilityChange);
  }

  refresh(now = new Date()) {
    const active = this.#cards.filter((card) => this.#isActive(card, now));

    this.#cards.forEach((card) => {
      card.element.classList.toggle(NowPlaying.ACTIVE_CLASS, active.includes(card));
      card.element.classList.toggle(NowPlaying.PAST_CLASS, card.endsAt <= now);
    });

    if (this.#changed(active)) {
      this.#announce(active);
      this.#scrollIntoView(active[0]);
    }

    this.#lastActive = active;

    if (this.#cards.every((card) => card.endsAt <= now)) {
      this.stop();
    }
  }

  stop() {
    window.clearInterval(this.#timer);
    document.removeEventListener('visibilitychange', this._onVisibilityChange);
  }

  _onVisibilityChange() {
    if (document.visibilityState === 'visible') {
      this.refresh();
    }
  }

  #isActive(card, now) {
    return card.startsAt <= now && now < card.endsAt;
  }

  #changed(active) {
    return active.length !== this.#lastActive.length || active.some((card, index) => card !== this.#lastActive[index]);
  }

  #announce(active) {
    const region = this.#liveRegion();
    region.textContent = active.length ? `Now playing: ${active.map((card) => card.element.querySelector('strong').textContent).join(', ')}` : '';
  }

  #liveRegion() {
    let region = document.getElementById('now-playing-live');
    if (!region) {
      region = ConferenceBox.html('<div id="now-playing-live" class="visually-hidden" aria-live="polite"></div>');
      document.body.append(region);
    }
    return region;
  }

  #scrollIntoView(card) {
    if (!card || this.#lastActive.length === 0) {
      return;
    }

    card.element.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
};
