#!/bin/zsh

########################
# HOW THIS SCRIPT WORKS
########################
# 1. Install Mise if missing and add Mise and Homebrew to PATH.
# 2. Create the dotfile symlinks declared in the repository's mise.toml.
# 3. Ensure declared packages, repos, macOS preferences, and Mise tools.
#    Mise uses the tool lockfiles; existing matching repos are left unchanged.
#    Check developer tools before installing packages and applying the remaining setup.
# 4. Copy the Unicode Hex Input keyboard layout when missing or changed.
# 5. Ensure ~/.hushlogin exists to suppress the last-login message.
########################

# Let's set script options first.

# The `errexit` option causes the script to exit immediately if any command
# within this script exits with a non-zero status.
set -o errexit
# The `nounset` option causes the script to exit if any variable is used
# before being set.
set -o nounset
# The `pipefail` option causes a pipeline to produce a failure return code
# if any command in the pipeline fails.
set -o pipefail

# The TRACE variable is used to turn on debugging mode.
# Can be used like this: `TRACE=1 script/config/setup.sh`
# The `${TRACE-0}` syntax is used to substitute a default value (0)
# if the variable TRACE is not set.
if [[ "${TRACE-0}" == "1" ]]; then
    # If TRACE is set to `1`, the `xtrace` option is set, which enables
    # debugging by printing each command and its arguments to standard error
    # before executing.
    set -o xtrace
fi

# Let's store the required paths in variables.

# DOTFILES will contain the root directory of this repo.
#
# Breaking it down:
# - `${(%):-%N}`: This is a zsh-specific parameter expansion.
#   %N gives the script name and the surrounding (%) gives the absolute path.
# - `dirname `${(%):-%N}"": This command takes the absolute path to the script
#   and returns the path to the script's directory.
# - `cd "$( dirname "${(%):-%N}" )" && cd ../..`: This command first changes
#   to the script's directory and then moves up two directories.
# - `pwd`: This command prints the current working directory, which is now
#   the repository root, two levels above the script's directory.
# - `$( cd "$( dirname "${(%):-%N}" )" && cd ../.. && pwd )`:
#   This entire command substitution returns the absolute path of the repository
#   root, two levels above the script's directory.
DOTFILES="$( cd "$( dirname "${(%):-%N}" )" && cd ../.. && pwd )"

MISE="$HOME/.local/bin/mise"

# Bootstrap Mise through its official checksum-verifying installer when missing.
if [[ ! -x "$MISE" ]]; then
    echo "🛠   Installing Mise..."
    curl -fsSL https://mise.run | MISE_INSTALL_PATH="$MISE" MISE_INSTALL_HELP=0 sh
fi
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Link dotfiles, including the global Mise configuration, without forcing conflicts.
echo
echo "🛠   Creating symlinks..."
"$MISE" --cd "$DOTFILES" dot apply --yes
echo "🛠   Creating symlinks... done."

# Check the compiler/SDK, plus first-launch readiness when full Xcode is selected.
if ! xcrun --sdk macosx --show-sdk-path >/dev/null 2>&1 ||
   ! xcrun --sdk macosx clang --version >/dev/null 2>&1; then
    echo "🚫 ERROR: Apple's compiler and macOS SDK are not ready. Install Xcode manually and complete its setup, then rerun." >&2
    echo "Select full Xcode when needed: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer" >&2
    exit 1
fi
case "$(xcode-select -p)" in
    *.app/Contents/Developer)
        if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
            echo "🚫 ERROR: Complete Xcode's first launch and licence setup, then rerun." >&2
            exit 1
        fi
        ;;
esac

# Reconcile declared state without upgrades, repo updates, or local project builds.
echo
echo "🛠   Applying Mise setup..."
"$MISE" --cd "$DOTFILES" bootstrap --yes --skip-dirty --only packages,repos,macos-defaults,tools
echo "🛠   Applying Mise setup... done."

# Copying fixed Unicode Hex Input keyboard layout
echo
echo "⌨️  Copying Unicode Hex Input keyboard layout..."

KEYBOARD_LAYOUT_SOURCE="$DOTFILES/script/keyboard-layout/unicode.keylayout"
KEYBOARD_LAYOUT_TARGET="$HOME/Library/Keyboard Layouts/unicode.keylayout"

if [[ ! -f "$KEYBOARD_LAYOUT_TARGET" ]] || ! cmp -s "$KEYBOARD_LAYOUT_SOURCE" "$KEYBOARD_LAYOUT_TARGET"; then
    mkdir -p "$(dirname "$KEYBOARD_LAYOUT_TARGET")"
    cp "$KEYBOARD_LAYOUT_SOURCE" "$KEYBOARD_LAYOUT_TARGET"
    echo "Keyboard layout is copied to $KEYBOARD_LAYOUT_TARGET."
else
    echo "Keyboard layout already exists and is identical. Not copying."
fi
echo
echo "⌨️  Copying Unicode Hex Input keyboard layout... done."

# Ensuring .hushlogin exists to get rid of "Last login..." message
echo
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin..."
touch "$HOME/.hushlogin"
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin... done."

echo
echo "🚀  Setup complete. Run \`reload\` in the calling shell, or restart the terminal."
