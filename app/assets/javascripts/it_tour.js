//= require jquery
//= require 'it_tour/vendor/jquery.plugin'
//= require 'it_tour/vendor/jquery.countdown'
//= require 'it_tour/vendor/jquery.scroll_to'
//= require 'it_tour/lib/lightbox'
//= require_self

$(function() {
  var links = $('nav a[href*="#"]');
  var sections = links.map(function() {
    var id = this.getAttribute('href').split('#')[1];
    return document.getElementById(id);
  }).get().filter(Boolean);

  if ('IntersectionObserver' in window && sections.length) {
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (!entry.isIntersecting) { return; }
        links.removeClass('active');
        links.filter('[href$="#' + entry.target.id + '"]').addClass('active');
      });
    }, { rootMargin: '-40% 0px -50% 0px' });

    sections.forEach(function(section) { observer.observe(section); });
  }

  links.on('click', function(event) {
    var target = document.getElementById(this.getAttribute('href').split('#')[1]);
    if (!target) { return; }
    event.preventDefault();
    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });

  Lightbox.start();
});
