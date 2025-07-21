#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find "$SCRIPT_DIR/patched" -type f ! -name '.gitkeep' -delete

docker run --pull always --rm -v "$SCRIPT_DIR/original/":/in -v "$SCRIPT_DIR/patched":/out nerdfonts/patcher --complete
