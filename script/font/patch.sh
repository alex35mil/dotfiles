#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prepare the Python environment for glyph centering
VENV_DIR="$SCRIPT_DIR/.venv"
if ! "$VENV_DIR/bin/python3" -c 'from fontTools.ttLib import TTFont' >/dev/null 2>&1; then
  rm -rf "$VENV_DIR"
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/python3" -m pip install -q fonttools
fi

find "$SCRIPT_DIR/patched" -type f ! -name '.gitkeep' -delete

docker run --pull always --rm -v "$SCRIPT_DIR/original/":/in -v "$SCRIPT_DIR/patched":/out nerdfonts/patcher --complete --careful

# Center Nerd Font icon glyphs within the monospace cell
"$VENV_DIR/bin/python3" "$SCRIPT_DIR/center-glyphs.py" "$SCRIPT_DIR/patched"
