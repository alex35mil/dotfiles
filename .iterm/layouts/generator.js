const fs   = require('fs');
const cp   = require('child_process');
const path = require('path');
const yaml = require('js-yaml');

module.exports = {

  writeConfig(args, rawConfig) {
    const name = args[2];
    const root = args[3];

    if (!name) {
      throw new Error('Provide project or template name');
    }

    const configDir = path.resolve(process.env.HOME, '.teamocil');

    try {
      fs.accessSync(configDir, fs.W_OK);
    } catch (err) {
      fs.mkdirSync(configDir);
    }

    const configLocation = path.join(configDir, `${name}.yml`);
    const userParams     = root ? { name, root } : { name };
    const coreConfig     = Object.assign({}, userParams, rawConfig);
    const jsConfig       = { windows: [ coreConfig ] };
    const yamlConfig     = yaml.safeDump(jsConfig);

    try { cp.exec(`rm ${configDir}/*`); } catch (err) {}

    fs.writeFileSync(configLocation, yamlConfig);
  },

};
