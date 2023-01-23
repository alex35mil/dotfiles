#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "🛠   Building Zellij statusbar..."

ZELLIJ_STATUSBAR_SRC="$DOTFILES/user/bin/zellij/statusbar"
ZELLIJ_STATUSBAR_DEST="$DOTFILES/user/cfg/zellij/plugins"
ZELLIJ_STATUSBAR_BIN="statusbar.wasm"

mkdir -p "$ZELLIJ_STATUSBAR_DEST"
rm "$ZELLIJ_STATUSBAR_DEST/statusbar.wasm" || true
cd $ZELLIJ_STATUSBAR_SRC
cargo build --release
cp "target/wasm32-wasi/release/$ZELLIJ_STATUSBAR_BIN" "$ZELLIJ_STATUSBAR_DEST/"

echo "🛠   Building Zellij statusbar... done."

echo ""
echo "🛠   Building Zellij runner..."

ZELLIJ_RUNNER_SRC="$DOTFILES/user/bin/zellij/runner"

cd $ZELLIJ_RUNNER_SRC
cargo install --path .

echo "🛠   Building Zellij runner... done."

echo ""
echo "👊  All done."
