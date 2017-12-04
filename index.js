#!/usr/bin/env node

/**
 * hello-nodejs-command.js
 */

var program = require('commander');

var pkg = require('./package.json')
var path = require('path');

var version = pkg.version
var mkdirp = require('mkdirp');

var fs = require("fs-extra");
var copydir = require('copy-dir');


program
  .version(version)
  .usage('<keywords>')
  .parse(process.argv);

if (!program.args.length) {
  program.help();
} else {
  //console.log('Keywords: ' + program.args);

  if (process.argv[2] == 'init') {
    gen(`${process.argv[3]}`)
  }
}

function gen(pathDir) {
  mkdirp(pathDir, function (err) {
    if (err) console.error(err)
    else {
      copydir.sync("./", pathDir, function (stat, filepath, filename) {
        if (stat === 'file' && path.extname(filepath) === '.key') {
          return false;
        }
        if (stat === 'directory' && path.extname(filepath) === '.git') {
          return false;
        }
        if (stat === 'directory' && filename === 'init') {
          return false;
        }
        if (stat === 'directory' && filename === 'node_modules') {
          return false;
        }
        return true;
        
      }, function (err) {
        console.log('ok');
      });
      console.log('new Project Generated:', process.argv[3]);
      

    }
  });
}