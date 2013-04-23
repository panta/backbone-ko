_link_model_to_viewmodel = (model, viewmodel) ->
  subscribe = (viewmodel, model, property) ->
    viewmodel.listenTo model, "change:#{property}", (model, value, options) ->
      viewmodel[property](value)
  for own property of model.attributes
    subscribe(viewmodel, model, property)

# based on
#   http://stackoverflow.com/questions/10622707/detecting-change-to-knockout-view-model/10622794#10622794
_link_viewmodel_to_model = (viewmodel, model) ->
  subscribe = (viewmodel, model, property) ->
    if (property != '__ko_mapping__') and viewmodel[property].subscribe
      viewmodel[property].subscribe (value) ->
        model.set(property, value)

  # loop through all the properties in the model
  for own property of viewmodel
    # if viewmodel.hasOwnProperty(property)
    if property == '__ko_mapping__'
      continue

    # if they're observable
    if viewmodel[property].subscribe
      
      # subscribe to changes
      subscribe(viewmodel, model, property)

bko.model2viewmodel = (model, opts) ->
  data = model.toJSON()
  viewmodel = ko.mapping.fromJS(data)
  _.extend(viewmodel, Backbone.Events)

  # changes to the model should be reflected to the viewmodel
  _link_model_to_viewmodel(model, viewmodel)

  # changes to viewmodel should be reflected to the model
  _link_viewmodel_to_model(viewmodel, model)

  viewmodel
