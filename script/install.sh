#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

DOTFILES_BIN="$DOTFILES/bin"
DOTFILES_HOME="$DOTFILES/home"

HOME_CONFIG="$HOME/.config"

# Ensuring first we don't overwrite anything
find "$DOTFILES_HOME" -type f -o -type l | while read SRC; do
    ITEM_PATH=${SRC#$DOTFILES_HOME}
    TARGET="$HOME$ITEM_PATH"

    if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
        echo "🚫 ERROR: $TARGET already exists and is not a symlink. Exiting."
        exit 1
    fi
done

# Building binaries
echo
echo "🛠   Building Zellij statusbar..."

ZELLIJ_STATUSBAR_SRC="$DOTFILES_BIN/zellij/statusbar"
ZELLIJ_STATUSBAR_DEST="$DOTFILES_HOME/.config/zellij/plugins"
ZELLIJ_STATUSBAR_BIN="statusbar.wasm"

mkdir -p "$ZELLIJ_STATUSBAR_DEST"
rm "$ZELLIJ_STATUSBAR_DEST/$ZELLIJ_STATUSBAR_BIN" || true
cd $ZELLIJ_STATUSBAR_SRC
cargo build --release
cp "target/wasm32-wasi/release/$ZELLIJ_STATUSBAR_BIN" "$ZELLIJ_STATUSBAR_DEST/"

echo "🛠   Building Zellij statusbar... done."

echo
echo "🛠   Building Zellij runner..."

ZELLIJ_RUNNER_SRC="$DOTFILES_BIN/zellij/runner"

cd $ZELLIJ_RUNNER_SRC
cargo install --locked --path .

cd $DOTFILES

echo "🛠   Building Zellij runner... done."

# Ensuring .config dir
echo
echo "🛠   Ensuring config directory: $HOME_CONFIG..."
mkdir -p "$HOME_CONFIG"
echo "🛠   Ensuring config directory: $HOME_CONFIG... done."

# Creating symlinks
echo
echo "🛠   Creating symlinks..."
find "$DOTFILES_HOME" -type f -o -type l | while read SRC; do
    ITEM_PATH=${SRC#$DOTFILES_HOME}
    TARGET="$HOME$ITEM_PATH"

    echo "🔖  Creating symlink: $SRC -> $TARGET..."
    mkdir -p "$(dirname "$TARGET")"
    ln -sf "$SRC" "$TARGET"
    echo "🔖  Creating symlink: $SRC -> $TARGET... done."
done
echo "🛠   Creating symlinks... done."

# Ensuring .hushlogin (to get rid of "Last login...")
echo
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin..."
touch "$HOME/.hushlogin"
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin... done."

echo
echo "👊  All done."

exec zsh -l
