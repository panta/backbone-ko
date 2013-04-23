# Backbone-KO

## [Knockout][] integration with [Backbone][] ##

This library provides a smooth integration of [Knockout][] with [Backbone][].

It is meant to be a simpler and lightweight alternative to [Knockback][]. For comparison, [Knockback][] core is 62Kb **unminified** (10Kb minified and gzipped), while [Backbone-KO][] is **3.5Kb unminified** and less than 1Kb minified and gzipped).

### Installation ###

Just copy the library from the `dist` folder to your javascript assets directory and include it using a script tag:

>  <script src="backbone-ko.js"></script>

### Usage ###

The library is contained in the `bko` namespace.

The simplest way to use it is through `bko.View`, a `Backbone.View` extended with [Knockout][] support.
`bko.View` will take care to create a KO view model from the Backbone `model` provided and to automatically apply the bindings to the view `el`:

```javascript
$(function() {
  var Person = Backbone.Model.extend({});
  var person = new Person({ first_name: "Thomas", last_name: "Jefferson", age: 83 });

  var personFormView = new bko.View({ el: $("#person"), model: person });
});
```

and the HTML:

```html
  <form id="person">
    <p>First name: <input data-bind="value: first_name" /></p>
    <p>Last name: <input data-bind="value: last_name" /></p>
    <p>E-mail: <input data-bind="value: email" /></p>
    <p>Age: <input data-bind="value: age" /></p>
  </form>
```

In the above example, the form will be automatically populated with values from the Backbone model, and the model will be updated whenever the user modifies the form fields. In other words a bi-directional binding is estabilished between the view and the model.

### Licence ###

Backbone-KO is © 2013 Marco Pantaleoni, released under the MIT licence. Use it, fork it.

[Knockout]: http://knockoutjs.com
[Backbone]: http://backbonejs.org
[Knockback]: http://kmalakoff.github.io/knockback
[Backbone-KO]: http://github.com/panta/backbone-ko
[bower]: http://bower.io
[mocha]: http://visionmedia.github.io/mocha
[CoffeeScript]: http://jashkenas.github.com/coffee-script/
[Node.js]: http://nodejs.org/
[Jasmine]: http://pivotal.github.com/jasmine/
