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

ALFRED_DIRS="\
  layouts \
  projects \
  scripts \
  shared \
"

HERE=$(dirname $0)


# Symlink configs
echo ""
for item in $DOTFILES
do
  [ -r "$HERE/$item" ] && \
  [ -e "$HERE/$item" ] && \
  ln -sfn "$HERE/$item" "$HOME/$item"

  echo "🔖  $HERE/$item -> $HOME/$item ... Done!"
done

# Source installed configs
if [[ -n $BASH_VERSION ]]; then
  source "$HOME/.bashrc"
elif [[ -n $ZSH_VERSION ]]; then
  source "$HOME/.zshrc"
fi
echo ""
echo "🌟  Reloaded!"

# Make history file, if it doesn't exist
touch $HISTFILE
echo ""
echo "📜  $HISTFILE ... Done!"

# Make .bin dir, if it doesn't exist
mkdir -p "$HOME/.bin"
echo ""
echo "🚀  $HOME/.bin ... Done!"

# Set permissions for kwm scripts
chmod -R +x "$HOME/.kwm/scripts/"
echo ""
echo "🕹  $HOME/.kwm ... Done!"

# Set permissions for Alfred filters
chmod -R u+x "$ALFRED/filters/"
echo ""
echo "🎩  $ALFRED ... Done!"

# Compile applescripts for Alfred
shopt -s nullglob
APPLESCRIPT="applescript"

echo ""
for alfred_sub_dir in $ALFRED_DIRS
do
  ALFRED_SOURCES="$HERE/.alfred/$alfred_sub_dir/*.$APPLESCRIPT"
  ALFRED_DEST="$ALFRED/$alfred_sub_dir"

  rm -rf $ALFRED_DEST && mkdir -p $ALFRED_DEST

  for alfred_script in $ALFRED_SOURCES
  do
    SCRIPT=$(basename $alfred_script .$APPLESCRIPT)
    SCRIPT_DEST="$ALFRED_DEST/$SCRIPT.scpt"

    osacompile -t scpt -o $SCRIPT_DEST $alfred_script

    echo "🔨  $alfred_script -> $SCRIPT_DEST ... Done!"
  done
done


# All done
echo ""
echo "👊  All done!"
