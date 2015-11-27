#!/bin/bash

DOTFILES_PATH="$HOME/Dev/System/dotfiles";

DOTFILES="\
  .bash/.bash_aliases \
  .bash/.bash_exports \
  .bash/.bash_functions \
  .bash/.bash_prompt \

  .bash_profile \
  .bashrc \

  .editorconfig \

  .gemrc \

  .gitconfig \
  .gitignore \

  .profile \

  .vimrc \
  .vim/colors/Tomorrow-Night-Bright.vim \

  .atom/config.cson \
  .atom/init.coffee \
  .atom/keymap.cson \
  .atom/snippets.cson \
  .atom/styles.less \
";

for file in $DOTFILES; do
  [ -r "$DOTFILES_PATH/$file" ] && \
  [ -f "$DOTFILES_PATH/$file" ] && \
  ln -sfn "$DOTFILES_PATH/$file" "$HOME/$file";
done;
