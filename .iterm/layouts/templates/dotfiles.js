const generator = require('../generator');

generator.writeConfig(process.argv, {
  layout: 'even-vertical',
  panes: [
    'atom .',
    'git status',
  ],
});
