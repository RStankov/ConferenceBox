//= require vendor/underscore
//= require vendor/backbone
//= require vendor/backbone_bind_to
//= require it_tour/lib/swipe
window.Lightbox = {
  start: function(container = $('body')) {
    return container.on('click', '[data-src]', function(e) {
      var elements, index, model, target, view;
      target = $(e.target).closest('[data-src]')[0];
      index = 0;
      elements = container.find('[data-src]').map((i, el) => {
        if (el === target) {
          index = i;
        }
        return new Lightbox.Image($(el).data('src'));
      });
      model = new Lightbox.Items({
        items: elements.toArray(),
        index: index
      });
      view = new Lightbox.View({
        model: model
      });
      container.append(view.el);
      return view.render();
    });
  }
};

Lightbox.Image = class Image {
  constructor(src) {
    this.src = src;
    this.isLoaded = false;
    this.width = 0;
    this.height = 0;
  }

  load(callback) {
    if (this.isLoaded) {
      return callback(this);
    }
    this.image = new window.Image;
    this.image.onload = () => {
      this.isLoaded = true;
      this.width = this.image.width;
      this.height = this.image.height;
      delete this.image;
      return callback(this);
    };
    return this.image.src = this.src;
  }

};

Lightbox.Items = (function() {
  class Items extends Backbone.Model {
    index(value) {
      if (value === void 0) {
        return this.get('index');
      } else {
        return this.set('index', value);
      }
    }

    item(index = this.index()) {
      return this.get('items')[index];
    }

    count() {
      return this.get('items').length;
    }

    previous() {
      var index;
      index = this.get('index') - 1;
      return this.index(index >= 0 ? index : this.count() - 1);
    }

    next() {
      var index;
      index = this.get('index') + 1;
      return this.index(index <= this.count() - 1 ? index : 0);
    }

  };

  Items.prototype.defaults = {
    'index': 0,
    'items': []
  };

  return Items;

}).call(this);

Lightbox.View = (function() {
  class View extends Backbone.View {
    initialize() {
      return this.bindTo(window, 'keyup', 'keyUp');
    }

    keyUp(e) {
      switch (e.keyCode) {
        case 27:
          return this.close();
        case 37:
          return this.previous();
        case 39:
          return this.next();
      }
    }

    close() {
      this.$el.parent().removeClass('lightbox-parent');
      return this.remove();
    }

    render() {
      this.$el.observeSwipe();
      this.$el.parent().addClass('lightbox-parent');
      this.$el.html(this.template);
      this.$container = this.$el.find('.lb-container');
      this.cloak = new Lightbox.Cloak(this.$el.find('.lb-cloak'));
      this.renderImage();
      return this;
    }

    next() {
      return this.model.next();
    }

    previous() {
      return this.model.previous();
    }

    renderImage() {
      this.cloak.cover(this.$container.find('img'));
      return this.model.item().load((image) => {
        image = $('<img />').prop('src', image.src);
        image.appendTo(this.$container);
        image.css({
          marginTop: (this.$container.height() - image.height()) / 2
        });
        return this.cloak.uncover(image);
      });
    }

  };

  View.prototype.tagName = 'div';

  View.prototype.className = 'lightbox';

  View.prototype.template = "<a class=\"lb-button lb-close\">✕</a>\n<div class=\"lb-container\">\n  <img width=\"50%\" height=\"50%\" />\n</div>\n<div class=\"lb-cloak\"></div>\n<div class=\"lb-controls\">\n  <a class=\"lb-button lb-previous\">&larr;</a>\n  <a class=\"lb-button lb-next\">&rarr;</a>\n</div>";

  View.prototype.events = {
    'click .lb-close': 'close',
    'click .lb-previous': 'previous',
    'click .lb-next': 'next',
    'swipe:right': 'previous',
    'swipe:left': 'next'
  };

  View.prototype.bindToModel = {
    'change:index': 'renderImage'
  };

  return View;

}).call(this);

Lightbox.Cloak = class Cloak {
  constructor(el1) {
    this.el = el1;
  }

  cover(item) {
    if (item.length === 0) {
      return;
    }
    this.el.stop(true, true).fadeIn().css(this.dimensionsOf(item));
    return item.remove();
  }

  uncover(item) {
    if (item.length === 0) {
      return;
    }
    this.el.animate(this.dimensionsOf(item), () => {
      this.el.fadeOut();
      return item.css({
        opacity: 100
      }).fadeIn();
    });
    return item.css({
      opacity: 0
    });
  }

  dimensionsOf(el) {
    return {
      top: el.offset().top,
      left: el.offset().left,
      width: el.width(),
      height: el.height()
    };
  }

};

