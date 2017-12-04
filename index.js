#!/usr/bin/env node

/**
 * hello-nodejs-command.js
 */

var program = require('commander');

var pkg = require('./package.json')

var path = require('path');

var version = pkg.version
var mkdirp = require('mkdirp');
var copydir = require('copy-dir');


program
  .version(version)
  .option('-i, --init <dir>', 'generate a new rico project')
  .usage('<keywords>')
  .usage('[options]')
  .parse(process.argv);


if (program.init) {
  gen(`${program.init}`)
} else {
  program.help();
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
        //console.log('ok');
      });
      console.log('Success! project generated! Path:', process.argv[3]);
    }
  });
}