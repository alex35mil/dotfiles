#!/bin/bash

FILES="\
  .config/nix \
  .config/nixpkgs \
  .config/user \
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
  echo "      $DOTFILES/$FILE -> $HOME/$FILE..."
  [ -r "$DOTFILES/$FILE" ] && \
  [ -e "$DOTFILES/$FILE" ] && \
  ln -sfn "$DOTFILES/$FILE" "$HOME/$FILE"
  echo "      $DOTFILES/$FILE -> $HOME/$FILE... done."
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

# Apply Home Manager configuration
echo ""
echo "🚀  Applying Home Manager configuration..."
home-manager switch
echo "🚀  Applying Home Manager configuration... done."

echo ""
echo "👊  All done."
