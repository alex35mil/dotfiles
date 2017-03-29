#!/usr/bin/env osascript -l JavaScript

function run() {
  const Docker = Library('docker');

  Docker.run('~/Dev/Projects/minima.pro/minima', {
    web: 'cd web',
    api: 'cd api',
    servers: './start',
  });
}
