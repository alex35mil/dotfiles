#!/usr/bin/env osascript -l JavaScript

function run() {
  const Everwise = Library('everwise');

  Everwise.run('~/Dev/Projects/shakacode.com/consulting/everwise/tasmania', {
    client: 'cd spas',
    api: 'git status',
    clientServer: 'cd spas && yarn start',
    apiServer: 'foreman start -f Procfile.dev',
  });
}
