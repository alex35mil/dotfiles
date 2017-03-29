#!/usr/bin/env osascript -l JavaScript

function run() {
  const Dotfiles = Library('dotfiles');

  Dotfiles.run('~/Dev/System/dotfiles', {
    vim: 'vim',
    cli: 'git status',
  });
}
