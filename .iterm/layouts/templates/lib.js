const generator = require('../generator');

generator.writeConfig(process.argv, {
  layout: 'tiled',
  panes: [
    'atom .',
    'git status',
    'npm start',
  ],
});
