/*
 Backbone.BindTo

 Author: Radoslav Stankov
 Project site: https://github.com/RStankov/backbone-bind-to
 Licensed under the MIT License.
*/
var BackboneView, BindToView, root;

root = this;

BackboneView = root.Backbone.View;

BindToView = class BindToView extends BackboneView {
  constructor(...args) {
    var eventName, methodName, ref, ref1;
    super(...args);
    if (this.model) {
      ref = this.bindToModel;
      for (eventName in ref) {
        methodName = ref[eventName];
        this.bindTo(this.model, eventName, methodName);
      }
    }
    if (this.collection) {
      ref1 = this.bindToCollection;
      for (eventName in ref1) {
        methodName = ref1[eventName];
        this.bindTo(this.collection, eventName, methodName);
      }
    }
  }

  bindTo(object, eventName, methodName) {
    var callback;
    callback = typeof methodName === 'function' ? methodName : this[methodName];
    if (!callback) {
      throw new Error(`Method ${methodName} does not exists`);
    }
    if (typeof callback !== 'function') {
      throw new Error(`${methodName} is not a function`);
    }
    if (object.on === Backbone.Events.on) {
      this.listenTo(object, eventName, callback);
    } else {
      if (this._binded == null) {
        this._binded = [];
      }
      this._binded.push(object);
      Backbone.$(object).on(`${eventName}.bindToEvent`, _.bind(callback, this));
    }
    return this;
  }

  unbindFromAll() {
    var element, i, len, ref;
    if (this.model && this.model.off) {
      this.model.off(null, null, this);
    }
    if (this.collection && this.collection.off) {
      this.collection.off(null, null, this);
    }
    if (this._binded) {
      ref = this._binded;
      for (i = 0, len = ref.length; i < len; i++) {
        element = ref[i];
        Backbone.$(element).off('.bindToEvent');
      }
    }
    delete this._binded;
    this.stopListening();
    return this;
  }

  remove() {
    this.unbindFromAll();
    return super.remove();
  }

};

Backbone.BindTo = {
  VERSION: '1.1.0',
  noConflict: function() {
    root.Backbone.View = BackboneView;
    return BindToView;
  },
  View: BindToView
};

root.Backbone.View = Backbone.BindTo.View;

