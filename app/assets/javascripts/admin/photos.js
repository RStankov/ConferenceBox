//= require vendor/jquery.ui.sortable
//= require vendor/plupload
//= require vendor/underscore
//= require vendor/backbone
//= require vendor/backbone_bind_to

$('#js-photos').each(function() {
  var PhotoStore, PhotosView, Uploader, uploader;
  Uploader = class Uploader {
    constructor(url) {
      this.uploader = new plupload.Uploader({
        browse_button: 'js-photo-upload',
        runtimes: 'html5',
        max_file_size: '20mb',
        url: url,
        filters: [
          {
            title: 'Photos:',
            extensions: 'jpg,jpeg,png'
          }
        ]
      });
      this.uploader.init();
      this.uploader.bind('FilesAdded', (uploader, files) => {
        var file, j, len;
        for (j = 0, len = files.length; j < len; j++) {
          file = files[j];
          this.trigger('file:added', file.id);
        }
        return uploader.start();
      });
      this.uploader.bind('FileUploaded', (uploader, file, xhr) => {
        return this.trigger('file:uploaded', file.id, JSON.parse(xhr.response));
      });
      this.uploader.bind('Error', (uploader, response) => {
        this.trigger('file:error', response.file.id);
        this.$(`#photo-${response.file.id}`).remove();
        return alert('File transfer failed');
      });
    }

  };
  _.extend(Uploader.prototype, Backbone.Events);
  PhotoStore = {
    baseUrl: $(this).data('url'),
    ajax: function(url, options = {}) {
      return $.ajax(`${this.baseUrl}/${url}`, options);
    },
    reorder: function(ids) {
      return this.ajax('reorder', {
        type: 'patch',
        data: {
          ids: ids
        }
      });
    },
    remove: function(id) {
      return this.ajax(id, {
        type: 'delete'
      });
    },
    each: function(callback) {
      return $('script[type="text/json"]').each((i, el) => {
        var j, len, photo, photos, script;
        script = $(el);
        photos = JSON.parse(script.html());
        for (j = 0, len = photos.length; j < len; j++) {
          photo = photos[j];
          callback(photo);
        }
        return script.remove();
      });
    }
  };
  PhotosView = (function() {
    class PhotosView extends Backbone.View {
      photoWasAdded(fileId) {
        return this.$article.prepend(`<div id="photo-${fileId}" class="card m-1 loading"></div>`);
      }

      photoWasUploaded(fileId, data) {
        return this.$(`#photo-${fileId}`).replaceWith(this.photoHtml(data));
      }

      photoWasntUploaded(fileId) {
        this.$(`#photo-${fileId}`).remove();
        return alert('File transfer failed');
      }

      initialize() {
        this.$article = this.$('article');
        this.collection.each((photo) => {
          return this.$article.append(this.photoHtml(photo));
        });
        return this.$('article').sortable({
          placeholder: "ui-state-highlight",
          update: (e, ui) => {
            return this.collection.reorder(this.$article.find('div').map(function() {
              return $(this).data('id');
            }).toArray());
          }
        });
      }

      photoHtml(photo) {
        return `<div data-id="${photo.id}" class="card m-1">\n  <img src="${photo.asset_url}" class="card-img-top" />\n  <div class="card-footer text-center">\n    <button class="btn btn-sm btn-dark" data-action="delete">Delete</button>\n  </div>\n</div>`;
      }

      deletePhoto(e) {
        var element;
        element = $(e.target).closest('div');
        this.collection.remove(element.data('id'));
        return element.hide('fast', function() {
          return element.remove();
        });
      }

    };

    PhotosView.prototype.events = {
      'click [data-action="delete"]': 'deletePhoto'
    };

    PhotosView.prototype.bindToModel = {
      'file:added': 'photoWasAdded',
      'file:uploaded': 'photoWasUploaded',
      'file:error': 'photoWasntUploaded'
    };

    return PhotosView;

  }).call(this);
  uploader = new Uploader($(this).data('url'));
  return new PhotosView({
    el: this,
    model: uploader,
    collection: PhotoStore
  });
});

