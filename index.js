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
//.option("-m, --pod_mode <mode>", "Which setup pod mode to use")  

program
  .command('new <dir>')
  .description('Generate a new rico project')
  .option("-m, --pod_mode <mode>", "Which setup pod mode to use")
  .action(function (dir, options) {
    //console.log(options.pod_mode)
    newProject(dir)
  });

program.on('--help', function () {
  console.log('');
  console.log('  Examples:');
  console.log('');
  console.log('    $ rico new ./test');
  //console.log('    $ rico new ./test -m DutchAuction');
  console.log('');
});


program.parse(process.argv);

if (!program.args.length) program.help();

function newProject(pathDir) {
  mkdirp(pathDir, function (err) {
    if (err) console.error(err)
    else {
      copydir.sync(__dirname, pathDir, function (stat, filepath, filename) {

        if (filepath.indexOf(__dirname + "/contracts") !== -1) {
          return true;
        }
        if (filepath.indexOf(__dirname + "/build") !== -1) {
          return true;
        }
        if (filepath.indexOf(__dirname + "/exec") !== -1) {
          return true;
        }
        if (filepath.indexOf(__dirname + "/migrations") !== -1) {
          return true;
        }
        if (stat === 'file' && filename === 'rpcrun.bash') {
          return true;
        }

        return false;

      }, function (err) {
        //console.log('ok');
      });
      console.log('Success! project generated! Path:', process.argv[3]);
    }
  });
}