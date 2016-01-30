const generator = require('../generator');

const project = process.argv[2];

generator.writeConfig(process.argv, {
  layout: 'tiled',
  panes: [
    `cd ${project}-app && git status`,
    `cd ${project}-api && git status`,
    `cd ${project}-app && npm start`,
    `cd ${project}-api && rails server`,
  ],
});
