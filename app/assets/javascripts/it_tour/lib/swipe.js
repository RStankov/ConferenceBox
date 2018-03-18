(function($) {
  var checkData, onTouchStart, recordData, resetData, swipeDirectionFor;
  swipeDirectionFor = function(element) {
    var dx, dy, options, x1, x2, y1, y2;
    options = element.data('swipe:options');
    x1 = element.data('swipe:start:x1');
    x2 = element.data('swipe:start:x2');
    y1 = element.data('swipe:start:y1');
    y2 = element.data('swipe:start:y2');
    if (!((x1 != null) && (x2 != null) && (y1 != null) && (y2 != null))) {
      return false;
    }
    dx = x1 - x2;
    dy = y1 - y2;
    if (dx > 0) {
      return 'left';
    } else {
      if (Math.abs(dx) >= options.minX) {
        return 'right';
      }
    }
    if (dy > 0) {
      return 'down';
    } else {
      if (Math.abs(dy) >= options.minY) {
        return 'up';
      }
    }
    return false;
  };
  resetData = function() {
    return $(this).removeData(['swipe:start:x1', 'swipe:start:x2', 'swipe:start:y1', 'swipe:start:y2']).off('.swipeCheck');
  };
  checkData = function() {
    var direction, element;
    element = $(this);
    direction = swipeDirectionFor(element);
    if (direction) {
      element.trigger('swipe');
      element.trigger(`swipe:${direction}`);
    }
    return resetData.call(this);
  };
  recordData = function(jqEvent) {
    var e, ref;
    e = jqEvent.originalEvent;
    if ((e != null ? (ref = e.touches) != null ? ref.length : void 0 : void 0) !== 1) {
      return;
    }
    return $(this).data('swipe:start:x2', e.touches[0].pageX).data('swipe:start:y2', e.touches[0].pageY);
  };
  onTouchStart = function(jqEvent) {
    var e, ref;
    e = jqEvent.originalEvent;
    if ((e != null ? (ref = e.touches) != null ? ref.length : void 0 : void 0) !== 1) {
      return;
    }
    return $(this).data('swipe:start:x1', e.touches[0].pageX).data('swipe:start:y1', e.touches[0].pageY).bind({
      'touchmove.swipeCheck': recordData,
      'touchend.swipeCheck': checkData,
      'touchcancel.swipeCheck': resetData
    });
  };
  return $.fn.observeSwipe = function(options = {}) {
    if (!('ontouchstart' in document.documentElement)) {
      return this;
    }
    this.data('swipe:options', $.extend({
      minX: 30,
      minY: 30
    }, options));
    return this.on('touchstart', onTouchStart);
  };
})($);

