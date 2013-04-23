chai = require("chai")
assert = chai.assert
should = chai.should()

fs   = require('fs')
path = require('path')
_    = require('underscore')

Browser = require("zombie")

BROWSER_DEBUG = false
html_build_dir = path.join(__dirname, 'build')

_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
}

local_url = (html_filename) ->
  abs_path = path.resolve(path.join(html_build_dir, html_filename))
  "file://#{abs_path}"

browser = new Browser({ debug: BROWSER_DEBUG })

# describe "Loads pages", ->
#   it "Google.com", (done) ->
#     browser.visit "http://www.google.com", (e, browser) ->
#       browser.text("title").should.equal "Google"
#       done()

describe "Local page", ->
  it "loads local page", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      browser.text("title").should.equal "Basic test page"
      done()

  it "contains #content", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      should.exist browser.query("#content")
      done()

  it "js runs and library is instantiated", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      if e
        console.log("Error: #{e.message}")
      should.exist browser.window.bko
      done()

  it "bko.View gets a viewmodel", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      if e
        console.log("Error: #{e.message}")
      should.exist browser.window.personFormView
      should.exist browser.window.personFormView.model
      should.exist browser.window.personFormView.viewmodel
      done()

  it "bko.View initializes form elements", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      if e
        console.log("Error: #{e.message}")
      should.equal browser.field('first_name').value, "Thomas"
      should.equal browser.field('last_name').value, "Jefferson"
      should.equal browser.field('age').value, "83"
      done()

  it "bko.View model changes update form elements", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      if e
        console.log("Error: #{e.message}")
      view = browser.window.personFormView
      model = view.model
      model.set('first_name', "John")
      should.equal browser.field('first_name').value, "John"
      done()

  it "form changes propagate back to bko.View model", (done) ->
    browser.visit local_url('test1/index.html'), (e, browser) ->
      if e
        console.log("Error: #{e.message}")
      view = browser.window.personFormView
      model = view.model
      # console.log(model.toJSON())
      browser.fill('first_name', "Franklin").fill('last_name', "Roosevelt").fill('age', 63)
      # console.log(model.toJSON())
      should.equal model.get('first_name'), "Franklin"
      should.equal model.get('last_name'), "Roosevelt"
      should.equal model.get('age'), "63"
      done()
