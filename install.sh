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
  .vim/colors \

  .atom/config.cson \
  .atom/init.coffee \
  .atom/keymap.cson \
  .atom/snippets.cson \
  .atom/styles.less \
";

for item in $DOTFILES; do
  [ -r "$DOTFILES_PATH/$item" ] && \
  [ -e "$DOTFILES_PATH/$item" ] && \
  ln -sfn "$DOTFILES_PATH/$item" "$HOME/$item";
done;
