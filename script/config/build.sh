#!/bin/zsh

# Build and install the local Zellij binaries after setup.sh has prepared Mise.
set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

DOTFILES="$( cd "$( dirname "${(%):-%N}" )" && cd ../.. && pwd )"
DOTFILES_BIN="$DOTFILES/bin"
DOTFILES_HOME="$DOTFILES/home"
MISE="$HOME/.local/bin/mise"

# Zellij statusbar plugin
echo
echo "🛠   Building Zellij statusbar..."

ZELLIJ_STATUSBAR_SRC="$DOTFILES_BIN/zellij/statusbar"
ZELLIJ_STATUSBAR_DEST="$DOTFILES_HOME/.config/zellij/plugins"
ZELLIJ_STATUSBAR_BIN="statusbar.wasm"

mkdir -p "$ZELLIJ_STATUSBAR_DEST"
cd "$ZELLIJ_STATUSBAR_SRC"
"$MISE" exec -- cargo build --locked --release
cp "target/wasm32-wasip1/release/$ZELLIJ_STATUSBAR_BIN" "$ZELLIJ_STATUSBAR_DEST/"

echo "🛠   Building Zellij statusbar... done."

# Zellij runner
echo
echo "🛠   Building Zellij runner..."

ZELLIJ_RUNNER_SRC="$DOTFILES_BIN/zellij/runner"

cd "$ZELLIJ_RUNNER_SRC"
"$MISE" exec -- cargo install --locked --path .

echo "🛠   Building Zellij runner... done."
