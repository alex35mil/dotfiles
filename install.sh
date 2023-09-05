#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

HOME_CONFIG_DIR="$HOME/.config"

USER_FILES="user"
NIX_FILES="\
    nix \
    nixpkgs \
    home-manager \
"

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure .config dir
echo ""
echo "🛠   Ensuring config directory: $HOME_CONFIG_DIR..."
mkdir -p "$HOME_CONFIG_DIR"
echo "🛠   Ensuring config directory: $HOME_CONFIG_DIR... done."

# Symlink configs
echo ""
echo "🔖  Symlinking configs:"
for FILES in $NIX_FILES
do
    NIX_FILES_ORIGIN="$DOTFILES/nix/$FILES"
    NIX_FILES_DESTINATION="$HOME_CONFIG_DIR/$FILES"

    echo "      $NIX_FILES_ORIGIN -> $NIX_FILES_DESTINATION..."

    if [ ! -r "$NIX_FILES_ORIGIN" ] || [ ! -e "$NIX_FILES_ORIGIN" ]; then
        echo "Error: File $NIX_FILES_ORIGIN is missing or unreadable."
        exit 1
    fi

    ln -sfn "$NIX_FILES_ORIGIN" "$NIX_FILES_DESTINATION"
    echo "      $NIX_FILES_ORIGIN -> $NIX_FILES_DESTINATION... done."
done

USER_FILES_ORIGIN="$DOTFILES/$USER_FILES"
USER_FILES_DESTINATION="$HOME_CONFIG_DIR/$USER_FILES"

echo "      $USER_FILES_ORIGIN -> $USER_FILES_DESTINATION..."

if [ ! -r "$USER_FILES_ORIGIN" ] || [ ! -e "$USER_FILES_ORIGIN" ]; then
    echo "Error: File $NIX_FILES_ORIGIN is missing or unreadable."
    exit 1
fi

ln -sfn "$USER_FILES_ORIGIN" "$USER_FILES_DESTINATION"
echo "      $USER_FILES_ORIGIN -> $USER_FILES_DESTINATION... done."

# Ensure history file
echo ""
echo "📜  Ensuring history file: $HOME/.zsh_history..."
touch "$HOME/.zsh_history"
echo "📜  Ensuring history file: $HOME/.zsh_history... done."

# Ensure .hushlogin (to get rid of "Last login...")
echo ""
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin..."
touch "$HOME/.hushlogin"
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin... done."

# Build binaries
echo ""
echo "🛠️  Building binaries..."
$DOTFILES/build.sh
echo "🛠️  Building binaries... done."

# Apply Home Manager configuration
echo ""
echo "🚀  Applying Home Manager configuration..."
home-manager switch
echo "🚀  Applying Home Manager configuration... done."

echo ""
echo "👊  All done."
