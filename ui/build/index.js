const fs = require('fs')
const path = require('path');

// Read what files where built into the dist
const directoryPath = path.join(__dirname, '../dist');
const luaPath = path.join(__dirname, '../../fxmanifest.lua');

// Walk through the directoryy
var walk = function(dir, done) {
  var results = [];
  fs.readdir(dir, function(err, list) {
    if (err) return done(err);
    var i = 0;
    // Self starting Iffe, gets called recursively
    (function next() {
      var file = list[i++];
      if (!file) return done(null, results);
      file = path.resolve(dir, file);
      fs.stat(file, function(err, stat) {
        if (stat && stat.isDirectory()) {
          walk(file, function(err, res) {
            results = results.concat(res);
            next();
          });
        } else {
          let s = file.replaceAll(/.*(\\bcc-storage\\)/g, '').replaceAll(/\\/g, '/')
          let f = "\x20\x20'"+s+"'"
          console.log(`\x1b[35m[BCC-FileBuilder]\x1b[0m \x1b[32mFile indexed!\x1b[0m \x1b[4m\x1b[36m(${s})\x1b[0m\x1b[0m`)
          results.push(f);
          next();
        }
      });
    })();
  });
};

walk(directoryPath, function(err, results) {
  if (err) throw err;


  fs.readFile(luaPath, 'utf8', function (err,data) {
    if (err) {
      return console.log(err);
    }

    let fls = JSON.stringify(results)
    fls = fls.replaceAll(/(\[|\])/g, '').replaceAll(/(\")/g, "").replaceAll(/(\'\,)/g, "',\r\n")

    let outstring = `files {\r\n${fls}\r\n}`

    let output = data.replace(/files\s\{([^}]+)\}/g, outstring);

    fs.writeFile(luaPath, output, 'utf8', function (err) {
      if (err) return console.log(err);
      console.log(`\x1b[35m[BCC-FileBuilder]\x1b[0m \x1b[36mfxmanifest.lua updated!\x1b[0m`)
    });
  });
});