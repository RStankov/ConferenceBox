//= require not_a_conf/jquery
//= require not_a_conf/bootstrap.min
//= require not_a_conf/jquery.counterup.min
//= require not_a_conf/jquery.plugin
//= require not_a_conf/jquery.countdown
//= require not_a_conf/jquery.colorbox
//= require not_a_conf/custom
//= require_self

$(function() {
  $('[data-countdown]').each(function() {
    var element = $(this);
    element.countdown({
      until: new Date(element.data('countdown')),
      padZeroes: true,
    });
  });
});
