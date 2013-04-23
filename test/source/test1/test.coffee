Person = Backbone.Model.extend
  defaults: ->
    first_name: ""
    last_name: ""
    email: ""
    age: null

person1 = new Person({ first_name: "Thomas", last_name: "Jefferson", age: 83})
person2 = new Person({ first_name: "Benjamin", last_name: "Franklin", age: 84})

# person1_vm = bko.model2viewmodel(person1)

$ ->
  personFormView = new bko.View({el: $("#person"), model: person1})
  window.personFormView = personFormView
