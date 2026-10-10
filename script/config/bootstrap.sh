#!/bin/zsh

# Full ensure-only setup: common configuration, Zellij builds, and Neovide.
# Usage: script/config/bootstrap.sh
set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if (( $# != 0 )); then
    echo "Usage: $0" >&2
    exit 1
fi

DOTFILES="$( cd "$( dirname "${(%):-%N}" )" && cd ../.. && pwd )"
MISE="$HOME/.local/bin/mise"

"$DOTFILES/script/config/setup.sh"
"$DOTFILES/script/config/build.sh"

# The Neovide task installs into /Applications; also accept a user installation.
app_installed() {
    [[ -f "/Applications/$1/Contents/Info.plist" || -f "$HOME/Applications/$1/Contents/Info.plist" ]]
}

if ! app_installed "Neovide.app"; then
    echo
    echo "🛠   Installing Neovide from its existing source checkout..."
    "$MISE" --cd "$DOTFILES" run apps:neovide
    if ! app_installed "Neovide.app"; then
        echo "🚫 ERROR: Neovide is still missing after its build task." >&2
        exit 1
    fi
fi

echo
echo "🚀  Bootstrap complete. Run reload in the calling shell, or restart the terminal."
