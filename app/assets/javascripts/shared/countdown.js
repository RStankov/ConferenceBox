ConferenceBox.Countdown = class Countdown {
  static PERIODS = [
    ['Days', 24 * 60 * 60],
    ['Hours', 60 * 60],
    ['Minutes', 60],
    ['Seconds', 1],
  ];

  static start(root = document) {
    return Array.from(root.querySelectorAll('[data-countdown]'), (element) => new Countdown(element));
  }

  constructor(element) {
    this.element = element;
    this.until = new Date(element.dataset.countdown);
    this.sections = this.render();
    this.tick();
    this.timer = window.setInterval(() => this.tick(), 1000);
  }

  render() {
    const row = ConferenceBox.html('<span class="is-countdown"><span class="countdown-row countdown-show4"></span></span>');
    this.element.replaceChildren(row);

    return Countdown.PERIODS.map(([label]) => {
      const section = ConferenceBox.html(
        `<span class="countdown-section"><span class="countdown-amount">00</span><span class="countdown-period">${label}</span></span>`,
      );
      row.firstElementChild.append(section);
      return section.firstElementChild;
    });
  }

  tick() {
    let remaining = Math.max(0, Math.floor((this.until - Date.now()) / 1000));

    Countdown.PERIODS.forEach(([, seconds], index) => {
      const amount = Math.floor(remaining / seconds);
      remaining -= amount * seconds;
      this.sections[index].textContent = String(amount).padStart(2, '0');
    });

    if (remaining === 0 && this.until <= Date.now()) {
      window.clearInterval(this.timer);
    }
  }
};
