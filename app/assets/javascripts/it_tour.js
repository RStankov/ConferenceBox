//= require jquery
//= require 'it_tour/vendor/jquery.plugin'
//= require 'it_tour/vendor/jquery.countdown'
//= require 'it_tour/vendor/jquery.scroll_to'
//= require 'it_tour/vendor/jquery.scrollspy'
//= require 'it_tour/lib/lightbox'
//= require_self

$(function() {
  var headerHeight = 10 + ($('header').height() || 0);
  var body = $('body');
  var nav = body.find('nav');

  $(window).on('scroll', function() {
    nav.toggleClass('sticky', $(document).scrollTop() > headerHeight);
  }).trigger('scroll');

  Lightbox.start();
});
