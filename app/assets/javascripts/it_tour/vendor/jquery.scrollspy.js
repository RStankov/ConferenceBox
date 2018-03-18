(function($) {
  var ScrollSpy;
  ScrollSpy = class ScrollSpy {
    constructor(element, options) {
      options = $.extend({}, $.fn.scrollspy.defaults, options);
      this.selector = options.selector;
      this.offset = options.offset;
      this.element = $(element);
      this.element.on('click', 'a[href*=#]', (e) => {
        var hash;
        [element, hash] = this.findElementAndHash($(e.target));
        if (element) {
          e.preventDefault();
          return $.scrollTo(element, {
            duration: 300,
            onAfter: function() {
              return location.hash = hash;
            }
          });
        }
      });
      this.window = $(window);
      this.window.on('scroll', () => {
        return this.process();
      });
      this.window.on('load resize', () => {
        return this.refresh();
      });
      this.refresh();
    }

    refresh() {
      this.items = [];
      this.element.find(this.selector).map((_, link) => {
        var element, hash;
        [element, hash] = this.findElementAndHash($(link));
        if (element) {
          return [
            {
              offset: element.position().top,
              hash: hash
            }
          ];
        }
      }).sort(function(a, b) {
        return a[0] - b[0];
      }).each((_, value) => {
        if (value) {
          return this.items.push(value);
        }
      });
      return this.process();
    }

    findElementAndHash(href) {
      var element, hash, match;
      match = href.attr('href').match(/#.*/);
      hash = match && match[0];
      if (!hash) {
        return [];
      }
      element = $(hash);
      if (element.length > 0) {
        return [element, hash];
      } else {
        return [];
      }
    }

    process() {
      var i, item, j, len, maxScroll, nextOffset, ref, ref1, ref2, results, scrollTop;
      scrollTop = this.window.scrollTop() + this.offset;
      maxScroll = document.body.scrollHeight - this.window.height();
      if (scrollTop >= maxScroll) {
        this.activate((ref = this.items[this.items.length - 1]) != null ? ref.hash : void 0);
        return;
      }
      ref1 = this.items;
      results = [];
      for (i = j = 0, len = ref1.length; j < len; i = ++j) {
        item = ref1[i];
        nextOffset = (ref2 = this.items[i + 1]) != null ? ref2.offset : void 0;
        if (scrollTop >= item.offset && (!nextOffset || scrollTop <= nextOffset)) {
          this.activate(item.hash);
          break;
        } else {
          results.push(void 0);
        }
      }
      return results;
    }

    activate(target) {
      if (target === this.activeTarget) {
        return;
      }
      this.activeTarget = target;
      if (this.activeElements) {
        this.activeElements.removeClass('active');
      }
      return this.activeElements = this.element.find(this.selector + '[href*="' + target + '"]').addClass('active').trigger('activate');
    }

  };
  $.fn.scrollspy = function(option) {
    return this.each(function() {
      var data, element;
      element = $(this);
      data = element.data('scrollspy');
      if (!data) {
        element.data('scrollspy', (data = new ScrollSpy(this, typeof option === 'object' && option)));
      }
      if (typeof option === 'string') {
        return data[option]();
      }
    });
  };
  return $.fn.scrollspy.defaults = {
    offset: 10,
    selector: 'nav a'
  };
})($);

