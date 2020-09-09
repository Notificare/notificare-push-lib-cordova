import { exec } from 'child_process';
import * as fs from 'fs-extra';
import * as path from 'path';

import { ROOT } from '../build/helpers';
import { Logger } from '../logger';

// tslint:disable-next-line:no-var-requires
const MAIN_PACKAGE_JSON = require('../../package.json');

const DIST = path.resolve(ROOT, 'dist');
const NPM_FLAGS = '--tag beta';

const MIN_CORE_VERSION = '^5.1.0';
const RXJS_VERSION = '^5.5.0 || ^6.5.0';

const PACKAGE_JSON = {
  name: MAIN_PACKAGE_JSON.name,
  version: MAIN_PACKAGE_JSON.version,
  description: MAIN_PACKAGE_JSON.description,
  module: 'index.js',
  typings: 'index.d.ts',
  author: MAIN_PACKAGE_JSON.author,
  license: MAIN_PACKAGE_JSON.license,
  repository: {
    type: 'git',
    url: 'https://github.com/notificare/notificare-push-lib-cordova.git',
  },
  dependencies: {},
  peerDependencies: {
    '@ionic-native/core': MIN_CORE_VERSION,
    rxjs: RXJS_VERSION,
  },
};

function writePackageJson(data: any, dir: string) {
  const filePath = path.resolve(dir, 'package.json');
  fs.writeJSONSync(filePath, data);
}

function prepare(): string {
  const dir = path.resolve(DIST, '@ionic-native', 'plugins', 'notificare');
  writePackageJson(PACKAGE_JSON, dir);

  const ngxDir = path.join(dir, 'ngx');
  writePackageJson(PACKAGE_JSON, ngxDir);

  return dir;
}

async function publish(ignoreErrors = false) {
  Logger.verbose('Preparing');
  const pluginDir = prepare();

  Logger.profile('Publishing');
  const worker = (pkgDir: string) =>
    new Promise((resolve, reject) => {
      exec(`npm publish ${pkgDir} ${NPM_FLAGS}`, (err, stdout) => {
        if (stdout) {
          Logger.verbose(stdout.trim());
          resolve(stdout);
        }

        if (err) {
          if (!ignoreErrors) {
            if (err.message.includes('You cannot publish over the previously published version')) {
              Logger.verbose('Ignoring duplicate version error.');
              return resolve();
            }
            reject(err);
          } else {
            resolve();
          }
        }
      });
    });

  try {
    await worker(pluginDir);
    Logger.info('Done publishing!');
  } catch (e) {
    Logger.error('Error publishing!');
    Logger.error(e);
  }
  Logger.profile('Publishing');
}

publish().catch(e => console.log(`Something went wrong: ${e}`));
