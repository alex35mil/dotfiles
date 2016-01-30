#!/bin/bash

# Install cask
brew tap caskroom/cask

# Install apps
brew cask install iterm2
brew cask install spectacle
brew cask install dropbox
brew cask install onepassword
brew cask install google-chrome-canary
brew cask install google-chrome
brew cask install torbrowser

# To maintain cask:
# brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup
