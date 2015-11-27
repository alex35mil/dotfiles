#!/bin/bash

rm -rf ~/.dotfiles
git clone git@github.com:alexfedoseev/dotfiles.git ~/.dotfiles

ln -sfn ~/.dotfiles/.bash/.bash_aliases ~/.bash/.bash_aliases
ln -sfn ~/.dotfiles/.bash/.bash_exports ~/.bash/.bash_exports
ln -sfn ~/.dotfiles/.bash/.bash_functions ~/.bash/.bash_functions
ln -sfn ~/.dotfiles/.bash/.bash_prompt ~/.bash/.bash_prompt

ln -sfn ~/.dotfiles/.bash_profile ~/.bash_profile
ln -sfn ~/.dotfiles/.bashrc ~/.bashrc

ln -sfn ~/.dotfiles/.editorconfig ~/.editorconfig

ln -sfn ~/.dotfiles/.gemrc ~/.gemrc

ln -sfn ~/.dotfiles/.gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/.gitignore ~/.gitignore

ln -sfn ~/.dotfiles/.profile ~/.profile

ln -sfn ~/.dotfiles/.vimrc ~/.vimrc
ln -sfn ~/.dotfiles/.vim/colors/Tomorrow-Night-Bright.vim ~/.vim/colors/Tomorrow-Night-Bright.vim

ln -sfn ~/.dotfiles/.atom/config.cson ~/.atom/config.cson
ln -sfn ~/.dotfiles/.atom/init.coffee ~/.atom/init.coffee
ln -sfn ~/.dotfiles/.atom/keymap.cson ~/.atom/keymap.cson
ln -sfn ~/.dotfiles/.atom/snippets.cson ~/.atom/snippets.cson
ln -sfn ~/.dotfiles/.atom/styles.less ~/.atom/styles.less
