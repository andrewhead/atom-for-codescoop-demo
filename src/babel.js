'use strict'

var crypto = require('crypto')
var path = require('path')
var defaultOptions = require('../static/babelrc.json')

// var babel = null
var babel = require('babel-core')
// require('babel/polyfill')
var babelVersionDirectory = null

var PREFIXES = [
  '/** @babel */',
  '"use babel"',
  '\'use babel\'',
  '/* @flow */'
]

var PREFIX_LENGTH = Math.max.apply(Math, PREFIXES.map(function (prefix) {
  return prefix.length
}))

exports.shouldCompile = function (sourceCode) {
  // return true
  var start = sourceCode.substr(0, PREFIX_LENGTH)
  return PREFIXES.some(function (prefix) {
    return start.indexOf(prefix) === 0
  })
}

exports.getCachePath = function (sourceCode) {
  if (babelVersionDirectory == null) {
    var babelVersion = require('babel-core/package.json').version
    babelVersionDirectory = path.join('js', 'babel', createVersionAndOptionsDigest(babelVersion, defaultOptions))
  }

  return path.join(
    babelVersionDirectory,
    crypto
      .createHash('sha1')
      .update(sourceCode, 'utf8')
      .digest('hex') + '.js'
  )
}

exports.compile = function (sourceCode, filePath) {
  if (!babel) {
    var Logger = require('babel-core/lib/transformation/file/logger')
    var noop = function () {}
    Logger.prototype.debug = noop
    Logger.prototype.verbose = noop
  }

  if (process.platform === 'win32') {
    filePath = 'file:///' + path.resolve(filePath).replace(/\\/g, '/')
  }

  var options = {filename: filePath}
  for (var key in defaultOptions) {
    options[key] = defaultOptions[key]
  }

  // Initialize presets list
  // Shims for a failed attempt at a port to a more recent Babel.
  /*
  if (!options.presets) {
    options.presets = []
  }
  options.presets.push(require.resolve("babel-preset-es2015"))
  options.presets.push(require.resolve("babel-preset-stage-0"))

  // Initialize plugins list
  if (!options.plugins) {
    options.plugins = []
  }
  options.plugins.push("transform-es2015-for-of")
  */
  var output = babel.transform(sourceCode, options).code

  /*
  var result = /(\s*\bfor\b.*\bof\b.*\s)/.exec(output)
  if (result)
    console.log(filePath, result[1])
  else
    console.log("No match found")
  */

  return output
}

function createVersionAndOptionsDigest (version, options) {
  return crypto
    .createHash('sha1')
    .update('babel-core', 'utf8')
    .update('\0', 'utf8')
    .update(version, 'utf8')
    .update('\0', 'utf8')
    .update(JSON.stringify(options), 'utf8')
    .digest('hex')
}
