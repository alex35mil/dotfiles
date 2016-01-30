#!/bin/bash

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
  .vim/snippets \

  .tmux.conf \
  .tmuxinator \

  .iterm \

  .atom/config.cson \
  .atom/init.coffee \
  .atom/keymap.cson \
  .atom/snippets.cson \
  .atom/styles.less \
  .atom/toolbar.cson \
"

for item in $DOTFILES
do
  [ -r "$PWD/$item" ] && \
  [ -e "$PWD/$item" ] && \
  ln -sfn "$PWD/$item" "$HOME/$item"

  echo "🍻  $PWD/$item -> $HOME/$item ... Done!"
done
