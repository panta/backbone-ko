(function() {
  var bko, root, _link_model_to_viewmodel, _link_viewmodel_to_model,
    __hasProp = {}.hasOwnProperty;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.bko || (root.bko = {});

  bko = root.bko;

  _link_model_to_viewmodel = function(model, viewmodel) {
    var property, subscribe, _ref, _results;

    subscribe = function(viewmodel, model, property) {
      return viewmodel.listenTo(model, "change:" + property, function(model, value, options) {
        return viewmodel[property](value);
      });
    };
    _ref = model.attributes;
    _results = [];
    for (property in _ref) {
      if (!__hasProp.call(_ref, property)) continue;
      _results.push(subscribe(viewmodel, model, property));
    }
    return _results;
  };

  _link_viewmodel_to_model = function(viewmodel, model) {
    var property, subscribe, _results;

    subscribe = function(viewmodel, model, property) {
      if ((property !== '__ko_mapping__') && viewmodel[property].subscribe) {
        return viewmodel[property].subscribe(function(value) {
          return model.set(property, value);
        });
      }
    };
    _results = [];
    for (property in viewmodel) {
      if (!__hasProp.call(viewmodel, property)) continue;
      if (property === '__ko_mapping__') {
        continue;
      }
      if (viewmodel[property].subscribe) {
        _results.push(subscribe(viewmodel, model, property));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  bko.model2viewmodel = function(model, opts) {
    var data, viewmodel;

    data = model.toJSON();
    viewmodel = ko.mapping.fromJS(data);
    _.extend(viewmodel, Backbone.Events);
    _link_model_to_viewmodel(model, viewmodel);
    _link_viewmodel_to_model(viewmodel, model);
    return viewmodel;
  };

  bko.View = Backbone.View.extend({
    constructor: function() {
      Backbone.View.apply(this, arguments);
      this.viewmodel = this.options.viewmodel || this.viewmodel || null;
      this._ko_bound = null;
      return this._ko_viewmodel = null;
    },
    initialize: function() {
      Backbone.View.prototype.initialize.apply(this, arguments);
      if (this.model || this.viewmodel) {
        return this._setModel(this.model, this.viewmodel);
      }
    },
    setElement: function(element, delegate) {
      this._ko_removeBinding();
      Backbone.View.prototype.setElement.apply(this, arguments);
      if (this.el && this.viewmodel) {
        this._ko_setBinding();
      }
      return this;
    },
    setModel: function(model, viewmodel) {
      if (model === this.model) {
        return this;
      }
      return this._setModel(model, viewmodel);
    },
    _setModel: function(model, viewmodel) {
      this.model = null;
      this.viewmodel = null;
      this.model = model;
      this.viewmodel = viewmodel;
      if (!this.viewmodel) {
        this.viewmodel = bko.model2viewmodel(this.model);
      }
      this._ko_setBinding();
      return this;
    },
    _ko_removeBinding: function() {
      if (this._ko_bound) {
        ko.cleanNode(this._ko_bound);
        this._ko_bound = null;
        this._ko_viewmodel = null;
      }
      return this;
    },
    _ko_setBinding: function() {
      if (this.el && this.viewmodel && (this.viewmodel !== this._ko_viewmodel)) {
        ko.applyBindings(this.viewmodel, this.el);
        this._ko_bound = this.el;
        this._ko_viewmodel = this.viewmodel;
      } else {
        if (!(this.el && this.viewmodel)) {
          this._ko_bound = null;
          this._ko_viewmodel = null;
        }
      }
      return this;
    }
  });

}).call(this);
