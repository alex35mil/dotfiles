#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

FILES="\
    nix \
    nixpkgs \
    user \
"

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure config dir
echo ""
echo "🛠   Ensuring config directory: $HOME/.config..."
mkdir -p "$HOME/.config"
echo "🛠   Ensuring config directory: $HOME/.config... done."

# Symlink configs
echo ""
echo "🔖  Symlinking configs:"
for FILE in $FILES
do
    echo "      $DOTFILES/$FILE -> $HOME/.config/$FILE..."
    [ -r "$DOTFILES/$FILE" ] && \
    [ -e "$DOTFILES/$FILE" ] && \
    ln -sfn "$DOTFILES/$FILE" "$HOME/.config/$FILE"
    echo "      $DOTFILES/$FILE -> $HOME/.config/$FILE... done."
done

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
