#!/usr/bin/env osascript -l JavaScript

function run() {
  const Shaka = Library('shaka');

  Shaka.run('~/Dev/Projects/shakacode.com/fng', {
    root: 'git status',
    client: 'cd client',
    server: 'foreman start -f Procfile.dev',
  });
}
