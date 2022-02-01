#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulas
brew upgrade --all

# Install tools
brew install \
  zsh \
  zsh-completions \
  git \
  vim --with-lua --with-override-system-vi \
  curl \
  wget --with-iri \
  coreutils \
  tree \
  pstree \
  mkcert \
  nss \
  ocaml \
  opam \
  node \
  yarn \
  go \
  doctl \
  kubernetes-cli \
  rbenv

# Remove outdated versions from the cellar
brew cleanup
