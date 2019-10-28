#!/usr/bin/env node

var APP_CLASS = 're.notifica.cordova.BaseApplication';

module.exports = function(context) {

    var fs = context.requireCordovaModule('fs'),
        path = context.requireCordovaModule('path');

    var platformRoot = path.join(context.opts.projectRoot, 'platforms/android');
    var manifestFile = path.join(platformRoot, 'AndroidManifest.xml');

    if (fs.existsSync(manifestFile)) {
        fs.readFile(manifestFile, 'utf8', function (err, data) {
            if (err) {
                throw new Error('Notificare Push Lib Cordova plugin - After Prepare Hook: Unable to find AndroidManifest.xml: ' + err);
            }

            if (data.indexOf(APP_CLASS) == -1) {
                var result = data.replace(/<application/g, '<application android:name="' + APP_CLASS + '"');
                fs.writeFile(manifestFile, result, 'utf8', function (err) {
                    if (err) {
                        throw new Error('Notificare Push Lib Cordova plugin - After Prepare Hook: Unable to write AndroidManifest.xml: ' + err);
                    }
                });
            }
        });
    }

};