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
brew install zsh
brew install zsh-completions
brew install bash-completion
brew install cmake
brew install git
brew install git-lfs
brew install nginx
brew install tmux
brew install reattach-to-user-namespace
brew install TomAnthony/brews/itermocil
brew install vim --override-system-vi
brew install wget --with-iri
brew install curl
brew install tree
brew install imagemagick --with-webp
brew install node
brew install postgresql
brew install leiningen
brew install rlwrap

# Remove outdated versions from the cellar
brew cleanup
