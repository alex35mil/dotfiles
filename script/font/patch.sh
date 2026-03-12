#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find "$SCRIPT_DIR/patched" -type f ! -name '.gitkeep' -delete

docker run --pull always --rm -v "$SCRIPT_DIR/original/":/in -v "$SCRIPT_DIR/patched":/out nerdfonts/patcher --complete --careful

# Center Nerd Font icon glyphs within the monospace cell
VENV_DIR="$SCRIPT_DIR/.venv"
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install -q fonttools
fi
"$VENV_DIR/bin/python3" "$SCRIPT_DIR/center-glyphs.py" "$SCRIPT_DIR/patched"
