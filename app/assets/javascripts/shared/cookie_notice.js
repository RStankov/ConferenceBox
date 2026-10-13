ConferenceBox.CookieNotice = class CookieNotice {
  static COOKIE = 'cookiesAccepted';
  static DAYS = 365;
  static DELAY = 1000;

  static start(options = {}) {
    if (ConferenceBox.cookies.get(CookieNotice.COOKIE)) { return null; }
    return new CookieNotice(options);
  }

  constructor({ title = 'Cookies & Privacy', message = 'This site uses cookies to personalize content.', accept = 'Accept cookies' } = {}) {
    this.element = ConferenceBox.html(`
      <div class="cookie-notice" role="region" aria-label="${title}">
        <h4>${title}</h4>
        <p>${message}</p>
        <button type="button">${accept}</button>
      </div>`);

    this.element.querySelector('button').addEventListener('click', () => this.accept());
    window.setTimeout(() => document.body.append(this.element), CookieNotice.DELAY);
  }

  accept() {
    ConferenceBox.cookies.set(CookieNotice.COOKIE, 'true', CookieNotice.DAYS);
    this.element.remove();
  }
};
