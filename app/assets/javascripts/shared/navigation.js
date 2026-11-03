ConferenceBox.Navigation = {
  start() {
    this.smoothScroll();
    this.scrollSpy();
    this.toggles();
    this.backToTop();
  },

  anchorLinks() {
    return Array.from(document.querySelectorAll('nav a[href*="#"]'));
  },

  targetOf(link) {
    const id = link.getAttribute('href').split('#')[1];
    return id ? document.getElementById(id) : null;
  },

  smoothScroll() {
    document.addEventListener('click', (event) => {
      const link = event.target.closest('a[href*="#"]');
      if (!link) { return; }
      const target = this.targetOf(link);
      if (!target) { return; }

      event.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      history.replaceState(null, '', `#${target.id}`);
    });
  },

  scrollSpy() {
    const links = this.anchorLinks();
    const sections = links.map((link) => this.targetOf(link)).filter(Boolean);
    if (!('IntersectionObserver' in window) || sections.length === 0) { return; }

    const observer = new IntersectionObserver((entries) => {
      entries.filter((entry) => entry.isIntersecting).forEach((entry) => {
        links.forEach((link) => link.classList.toggle('active', this.targetOf(link) === entry.target));
      });
    }, { rootMargin: '-40% 0px -50% 0px' });

    sections.forEach((section) => observer.observe(section));
  },

  toggles() {
    document.querySelectorAll('[data-toggle="collapse"]').forEach((button) => {
      button.addEventListener('click', () => {
        document.querySelectorAll(button.dataset.target).forEach((target) => target.classList.toggle('in'));
      });
    });
  },

  backToTop() {
    const button = document.querySelector('[data-back-to-top]');
    if (!button) { return; }

    const update = () => { button.hidden = window.scrollY < 50; };
    window.addEventListener('scroll', update, { passive: true });
    update();

    button.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  },
};
