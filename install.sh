#!/bin/bash

FILES="\
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

  .hyper.js \

  .iterm \

  .kwm \
  .khdrc \
  .ubersicht \

  .atom/config.cson \
  .atom/init.coffee \
  .atom/keymap.cson \
  .atom/snippets.cson \
  .atom/styles.less \
  .atom/toolbar.cson \

  .alfred/filters \
"

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ITERM="$HOME/.iterm"
ALFRED="$HOME/.alfred"

# Symlink configs
echo ""
echo "🔖  Symlinking configs:"
for FILE in $FILES
do
  [ -r "$DOTFILES/$FILE" ] && \
  [ -e "$DOTFILES/$FILE" ] && \
  ln -sfn "$DOTFILES/$FILE" "$HOME/$FILE"

  echo "   $DOTFILES/$FILE -> $HOME/$FILE ... Done"
done

# Source installed configs
if [[ -n $BASH_VERSION ]]; then
  source "$HOME/.bashrc"
elif [[ -n $ZSH_VERSION ]]; then
  source "$HOME/.zshrc"
fi
echo ""
echo "🌟  Loaded!"


# History file
touch $HISTFILE
echo ""
echo "📜  Makeing history file: $HISTFILE ... Done"


# .hushlogin (to get rid of "Last login...")
touch "$HOME/.hushlogin"
echo ""
echo "📋  Creating .hushlogin: $HOME/.hushlogin ... Done"


# kwm scripts
chmod -R +x "$HOME/.kwm/scripts/"
echo ""
echo "🕹  Setting permissions for kwm scripts: $HOME/.kwm ... Done"


# Alfred filters
chmod -R u+x "$ALFRED/filters/"
echo ""
echo "🎩  Setting permissions for Alfred filters: $ALFRED ... Done"


# iTerm projects
chmod -R u+x "$ITERM/layouts/projects/"
echo ""
echo "📐  Setting permissions for iTerm projects: $ITERM ... Done"


# JXA templates
shopt -s nullglob

echo ""
echo "🔨  Compiling JXA templates:"

OSA_LIBS_PATH="$HOME/Library/Script Libraries"
TEMPLATES="$HOME/.iterm/layouts/templates/*.js"

rm -rf "$OSA_LIBS_PATH" && mkdir -p "$OSA_LIBS_PATH"

for TEMPLATE in $TEMPLATES
do
  BUILD=$(basename $TEMPLATE .js)
  BUILD_DEST="$OSA_LIBS_PATH/$BUILD.scpt"

  osacompile -l JavaScript -o "$BUILD_DEST" $TEMPLATE

  echo "   $TEMPLATE -> $BUILD_DEST ... Done"
done


# All done
echo ""
echo "👊  All done!"
