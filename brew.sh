#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade --all

# Install
brew install git
brew install git-lfs
brew install nginx
brew install vim --override-system-vi
brew install wget --with-iri
brew install curl
brew install imagemagick --with-webp
brew install node
brew install postgresql
brew install leiningen
brew install rlwrap

# Remove outdated versions from the cellar
brew cleanup
