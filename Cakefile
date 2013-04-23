# Cakefile
# rib library
# Copyright (C) 2012 Marco Pantaleoni. All rights reserved.

util           = require('util')
fs             = require('fs')
path           = require('path')
glob           = require('glob')
findit         = require('findit')
{spawn, exec}  = require('child_process')
execSync       = require('exec-sync')
CoffeeScript   = require('coffee-script')
uglify         = require('uglify-js')
_              = require('underscore')
try
  eyes          = require('eyes')
  plain_inspect = eyes.inspector({ styles: false })
  color_inspect = eyes.inspector()
catch e
  eyes = {}
  eyes.inspect  = console.log
  plain_inspect = console.log
  color_inspect = console.log

src_dir   = path.join(__dirname, 'src')
build_dir = path.join(__dirname, 'build')
dist_dir  = path.join(__dirname, 'dist')

sources = [
  'setup.coffee',
  'mixins.coffee',
  'viewmodel.coffee',
  'views.coffee',
].map (filename) -> "src/#{filename}"

option '-B', '--builddir [DIR]', "directory for intermediate build products (default '#{build_dir}')"
option '-o', '--output [DIR]', "directory for distribution files (default '#{dist_dir}')"
option '-w', '--watch',  'continue to watch the files and rebuild them when they change'
option '-s', '--coverage', 'run coverage tests and report (test task only)'
option '-v', '--verbose', 'Use test verbose mode'

_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
}

cakelog = (message, color, explanation) ->
  # console.log bd_magenta + "[CAKE]" + reset + ' ' + (color or yellow) + message + reset + ' ' + (explanation or '')
  console.log "[CAKE] #{message} " + (explanation or '')

cakeerr = (message, color, explanation) ->
  # console.log red_bg + "[ERROR]" + reset + ' ' + (color or red) + message + reset + ' ' + (explanation or '')
  console.log "[ERROR] #{message} " + (explanation or '')

wait = (milliseconds, func) -> setTimeout func, milliseconds

# Extend a source object with the properties of another object (shallow copy).
extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

# Merge objects, returning a fresh copy with attributes from both sides. 
merge = (options, overrides) ->
  extend (extend {}, options), overrides

file_exists = (path) ->
  try
    stats = fs.statSync(path)
    return true
  catch e
    return false

handleError = (err) ->
  if err
    console.log err.stack

makedir = (dir) ->
  try
    #fs.mkdirSync dir, 0777
    execSync("mkdir -p #{dir}")
  catch e
    null

path_split = (pathname) ->
  components = pathname.split(/\/+/)
  if (components.length >= 1) and (components[0] == '')
    components[0] = '/'
  components

path_join = (components) ->
  path.join.apply(this, components)

getpaths = (opts) ->
  buildpath = opts.build_dir or build_dir
  buildpath = path.join(__dirname, buildpath) unless buildpath[0] = '/'
  outpath = opts.output or dist_dir
  outpath = path.join(__dirname, outpath) unless outpath[0] = '/'
  {
    src: src_dir
    build: buildpath
    dist: outpath
  }

MinifyJs = (dst, src, opts={}, encoding='utf8') ->
  cakelog "minifying #{src} -> #{dst}"
  jscode = fs.readFileSync(src, encoding)
  uglify_options = {
    strict_semicolons: true
    mangle_options: {except: ['$super']}
    gen_options: {ascii_only: true}
  }
  uglify_options = merge(uglify_options, opts)
  minified_jscode = uglify(jscode, uglify_options)
  fs.writeFileSync(dst, minified_jscode, encoding)

CoffeeCompile = (dst, src, opts={}, encoding='utf8') ->
  if not ('filename' of opts)
    opts.filename = src
  dst_dirname = path.dirname(dst)
  dst_extname = path.extname(dst)
  dst_basename = path.join(dst_dirname, path.basename(path.basename(dst), dst_extname))
  dst_js = dst
  makedir dst_dirname
  minify = false
  minify_opts = {}
  if 'minify' of opts
    minify = opts.minify
    delete opts['minify']
    if 'minify_opts' of opts
      minify_opts = opts.minify_opts
      delete opts['minify_opts']
    if minify
      dst_js = "#{dst_basename}.src.js"
      dst_minjs = "#{dst_basename}.js"
  keep_src = false
  if 'keep_src' of opts
    keep_src = opts.keep_src
    delete opts['keep_src']
  cakelog "compiling #{src} -> #{dst_js}"
  fs.writeFileSync(dst_js, CoffeeScript.compile(fs.readFileSync(src, encoding), opts))
  if minify
    MinifyJs(dst_minjs, dst_js, minify_opts, encoding)
    if not keep_src
      fs.unlink(dst_js)

concatenate = (dst, srcs, opts={}, encoding='utf8') ->
  cakelog "concatenating to #{dst}"
  dst_dirname = path.dirname(dst)
  dst_extname = path.extname(dst)
  dst_basename = path.join(dst_dirname, path.basename(path.basename(dst), dst_extname))
  dst_js = dst
  makedir dst_dirname
  code = []
  srcs.forEach (file) ->
    console.log("reading #{file}")
    code.push(fs.readFileSync(file, 'utf8'))
  fs.writeFileSync(dst, code.join("\n"), 'utf8')
  code

task 'build', 'Rebuild all built resources', ->
  invoke('build:js')

task 'clean', 'Remove everything that was built', ->
  invoke('clean:js')

task 'build:js', 'Build library', (opts) ->
  paths = getpaths opts

  build_coffee_dst = path.join(paths.build, 'backbone-ko.coffee')
  dist_js_dst = path.join(paths.dist, 'backbone-ko.js')
  concatenate(build_coffee_dst, sources)

  CoffeeCompile(dist_js_dst, build_coffee_dst, {bare: false, minify: true, keep_src: true})
  console.log 'Done.'

task 'clean:js', 'Remove built javascript', (opts) ->
  paths = getpaths opts
  try
    for file in fs.readdirSync paths.build
      filepath = path.join(paths.build, file)
      fs.unlink(filepath)
    fs.rmdir(paths.build)
  catch e
    null
  console.log 'Done.'

task 'test', 'Test the app', (options) ->
  # compile test files
  test_dir = path.join(__dirname, 'test')
  test_source_dir = path.join(test_dir, 'source')
  test_build_dir = path.join(test_dir, 'build')
  findit.find test_source_dir, (pathname, stat) ->
    file_ext = path.extname(pathname)
    pathname_rel = path.relative(test_source_dir, pathname)
    dst_pathname = path.join(test_build_dir, pathname_rel)
    dst_dirname = path.dirname(dst_pathname)
    dst_extname = path.extname(dst_pathname)
    dst_basename = path.basename(dst_pathname)
    makedir dst_dirname
    # console.log("TEST BUILD src:#{pathname} relative:#{pathname_rel}")
    if stat.isFile()
      if file_ext == '.coffee'
        dst_basename = path.join(dst_dirname, path.basename(path.basename(dst_pathname), dst_extname))
        dst_pathname = dst_basename + '.js'
        CoffeeCompile(dst_pathname, pathname, {bare: false, minify: false, keep_src: true})
      else if file_ext == '.html'
        lib_path = path.resolve(path.join(dist_dir, 'backbone-ko.js'))
        lib_src_path = path.resolve(path.join(dist_dir, 'backbone-ko.src.js'))
        dst_dir = path.resolve(path.dirname(path.join(test_build_dir, pathname_rel)))
        test_js_path = path.resolve(path.join(dst_dir, 'test.js'))
        cakelog "compiling template #{pathname} -> #{dst_pathname}"
        html_tpl_text = fs.readFileSync(pathname, 'utf8')
        html_tpl = _.template(html_tpl_text)
        html = html_tpl({
          filename: path.basename(pathname)
          pathname: pathname
          lib_dir: dist_dir
          backbone_ko: lib_path
          backbone_ko_src: lib_src_path
          test_js: test_js_path
        })
        fs.writeFileSync(dst_pathname, html, 'utf8')

  node_modules = path.join(__dirname, 'node_modules')
  node_bin = path.join(node_modules, '.bin')
  mocha_bin = path.join(node_bin, 'mocha')
  mocha = spawn mocha_bin, \
    ['--compilers', 'coffee:coffee-script', '-R', 'spec'], \
    { stdio: [process.stdin, process.stdout, process.stderr] }
  # mocha.stdout.on 'data', (data) ->
  #   console.log data
  # mocha.stderr.on 'data', (data) ->
  #   console.log data
  mocha.on 'close', (code) ->
    console.log("mocha process existed with code #{code}")
    process.exit(code)
