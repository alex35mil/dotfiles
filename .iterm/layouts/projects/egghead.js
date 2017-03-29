#!/usr/bin/env osascript -l JavaScript

function run() {
  const Shaka = Library('shaka');

  Shaka.run('~/Dev/Projects/shakacode.com/consulting/egghead/egghead-rails', {
    root: 'git status',
    client: 'cd client',
    server: 'PORT=3000 RACK_TIMEOUT=120000 foreman start -f Procfile.dev -m web=1,webpack-client-bundle=1,webpack-server-bundle=1',
  });
}
