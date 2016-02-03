#!/bin/bash

DOTFILES="\
  .bashrc \
  .bash_profile \

  .zshrc \
  .zsh_profile \

  .shell \

  .profile \

  .editorconfig \

  .gemrc \

  .gitconfig \
  .gitignore \

  .vimrc \
  .vim/colors \
  .vim/snippets \

  .tmux.conf \
  .tmuxinator \

  .iterm \
  .kwm \
  .ubersicht \

  .atom/config.cson \
  .atom/init.coffee \
  .atom/keymap.cson \
  .atom/snippets.cson \
  .atom/styles.less \
  .atom/toolbar.cson \
"

INSTALL_SCRIPT_DIR=$(dirname $0)

for item in $DOTFILES
do
  [ -r "$INSTALL_SCRIPT_DIR/$item" ] && \
  [ -e "$INSTALL_SCRIPT_DIR/$item" ] && \
  ln -sfn "$INSTALL_SCRIPT_DIR/$item" "$HOME/$item"

  echo "🍻  $INSTALL_SCRIPT_DIR/$item -> $HOME/$item ... Done!"
done
