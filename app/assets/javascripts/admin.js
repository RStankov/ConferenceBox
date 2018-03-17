//= require jquery
//= require jquery_ujs
//= require_tree ./admin

$(document).on('focus', 'textarea', function() {
  var namespace = 'sizer';
  var textarea  = $(this);
  var padding   = parseInt(textarea.css('paddingTop'), 10) + parseInt(textarea.css('paddingLeft'), 10);

  function calculateHeight() {
    textarea.height(1);
    textarea.height(Math.max(40, textarea.prop('scrollHeight') - padding));
  }

  calculateHeight();

  textarea.on("keypress.#{namespace} input.#{namespace} beforepaste.#{namespace}", calculateHeight);

  textarea.on("blur.#{namespace}", function() {
    calculateHeight();
    textarea.off(".#{namespace}");
  });
});

$(document).on('mousedown', 'select[multiple] option', function() {
  $(this).data('selected', $(this).prop('selected'));
});

$(document).on('mouseup', 'select[multiple] option', function() {
  $(this).prop('selected', !$(this).data('selected'));
});
