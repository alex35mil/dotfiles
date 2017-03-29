#!/usr/bin/env osascript -l JavaScript

function run() {
  const Lib = Library('lib');

  Lib.run('~/Dev/Libs/redux-interactions', {
    root: 'git status',
    build: 'cd examples/async-interactions',
    server: 'cd examples/flow-interactions',
  });
}
