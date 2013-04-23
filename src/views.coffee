bko.View = Backbone.View.extend
  constructor: ->
    # super()
    Backbone.View.apply(this, arguments)
    @viewmodel = @options.viewmodel or @viewmodel or null
    @_ko_bound = null
    @_ko_viewmodel = null

  initialize: ->
    # super()
    Backbone.View::initialize.apply(this, arguments)
    if @model or @viewmodel
      @_setModel(@model, @viewmodel)

  setElement: (element, delegate) ->
    @_ko_removeBinding()
    # super element, delegate
    Backbone.View::setElement.apply(this, arguments)
    if @el and @viewmodel
      @_ko_setBinding()
    @

  setModel: (model, viewmodel) ->
    if model is @model
      return @
    @_setModel(model, viewmodel)

  _setModel: (model, viewmodel) ->
    @model = null
    @viewmodel = null

    @model = model
    @viewmodel = viewmodel
    if not @viewmodel
      @viewmodel = bko.model2viewmodel(@model)
    @_ko_setBinding()
    @

  _ko_removeBinding: ->
    if @_ko_bound
      ko.cleanNode(@_ko_bound)
      @_ko_bound = null
      @_ko_viewmodel = null
    @

  _ko_setBinding: ->
    if @el and @viewmodel and (@viewmodel != @_ko_viewmodel)
      ko.applyBindings(@viewmodel, @el)
      @_ko_bound = @el
      @_ko_viewmodel = @viewmodel
    else
      if not (@el and @viewmodel)
        @_ko_bound = null
        @_ko_viewmodel = null
    @
