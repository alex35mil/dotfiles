const generator = require('../generator');

generator.writeConfig(process.argv, {
  layout: 'tiled',
  panes: [
    'atom . && git status',
    'cd client',
    'foreman start -f Procfile.dev',
  ],
});
