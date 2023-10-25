#!/bin/zsh

########################
# HOW THIS SCRIPT WORKS
########################
# To install these dotfiles, I will use the `find` command to collect and symlink
# all the configuration files from the `dotfiles/home` directory.
# However, I will make an exception for the files in the directories listed
# in the $UMBRELLA_DIRECTORIES array down below. Why? Since I add/remove files
# in these directories relatively often, I don't want to run the install script
# every time it happens. Symlinking the whole directory instead of each
# individual file would solve this.
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
# Can be used like this: `TRACE=1 script/install.sh`
# The `${TRACE-0}` syntax is used to substitute a default value (0)
# if the variable TRACE is not set.
if [[ "${TRACE-0}" == "1" ]]; then
    # If TRACE is set to `1`, the `xtrace` option is set, which enables
    # debugging by printing each command and its arguments to standard error
    # before executing.
    set -o xtrace
fi

# Let's store the required paths in variables.
#
# DOTFILES will contain the root directory of this repo.
#
# Breaking it down:
# - `${(%):-%N}`: This is a zsh-specific parameter expansion.
#   %N gives the script name and the surrounding (%) gives the absolute path.
# - `dirname `${(%):-%N}"": This command takes the absolute path to the script
#   and returns the path to the script's directory.
# - `cd "$( dirname "${(%):-%N}" )" && cd ..`: This command first changes
#   to the script's directory and then moves up one directory.
# - `pwd`: This command prints the current working directory, which is now
#   the parent directory of the script's directory).
# - `$( cd "$( dirname "${(%):-%N}" )" && cd .. && pwd )`:
#   This entire command substitution returns the absolute path of the parent
#   directory of the script's directory.
DOTFILES="$( cd "$( dirname "${(%):-%N}" )" && cd .. && pwd )"

DOTFILES_BIN="$DOTFILES/bin"
DOTFILES_HOME="$DOTFILES/home"

HOME_CONFIG="$HOME/.config"

# I want to symlink these directories instead of each individual file in them.
UMBRELLA_DIRECTORIES=(
    ".config/nvim"
    ".config/shell"
    ".config/zellij"
    ".config/raycast/scripts"
)

# Let's collect all the paths to configuration files in an associative array
declare -A PATHS

# `cd` to the $DOTFILES_HOME directory to get relative paths with `find`
cd $DOTFILES_HOME

# Here, I `find` all the files in the $DOTFILES_HOME directory,
# and if a file is inside one of the $UMBRELLA_DIRECTORIES,
# I add the directory to the $PATHS array.
# Otherwise, I add the file itself to the $PATHS array.
for file in $(find . -type f | sed 's|^\./||'); do
    dir=""

    for d in $UMBRELLA_DIRECTORIES; do
        if [[ $file == $d/* ]]; then
            dir=$d
            break
        fi
    done

    if [[ -n $dir ]]; then
        PATHS[$dir]="d"
    else
        PATHS[$file]="f"
    fi
done

# Before making any changes, let's ensure we don't overwrite anything
for loc in ${(o)${(k)PATHS}}; do
    local target="$HOME/$loc"

    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "🚫 ERROR: $target already exists and is not a symlink. Exiting."
        exit 1
    fi
done

# If we're good, let's ensure `.config` directory exists
echo
echo "🛠   Ensuring config directory: $HOME_CONFIG..."
mkdir -p "$HOME_CONFIG"
echo "🛠   Ensuring config directory: $HOME_CONFIG... done."

# And create the symlinks
echo
echo "🛠   Creating symlinks..."
for loc in ${(o)${(k)PATHS}}; do
    local src="$DOTFILES_HOME/$loc"
    local target="$HOME/$loc"
    local kind="${PATHS[$loc]}"

    echo "🔖  Creating symlink: $src -> $target..."

    mkdir -p "$(dirname "$target")"

    case "$kind" in
    f)
        ln -sf "$src" "$target"
        ;;
    d)
        ln -sfn "$src" "$target"
        ;;
    esac

    echo "🔖  Creating symlink: $src -> $target... done."
done
echo "🛠   Creating symlinks... done."

# Then, let's build the binaries from the `dotfiles/bin` directory

# Zellij statusbar plugin
echo
echo "🛠   Building Zellij statusbar..."

ZELLIJ_STATUSBAR_SRC="$DOTFILES_BIN/zellij/statusbar"
ZELLIJ_STATUSBAR_DEST="$DOTFILES_HOME/.config/zellij/plugins"
ZELLIJ_STATUSBAR_BIN="statusbar.wasm"

mkdir -p "$ZELLIJ_STATUSBAR_DEST"
rm "$ZELLIJ_STATUSBAR_DEST/$ZELLIJ_STATUSBAR_BIN" || true
cd $ZELLIJ_STATUSBAR_SRC
cargo build --release
cp "target/wasm32-wasi/release/$ZELLIJ_STATUSBAR_BIN" "$ZELLIJ_STATUSBAR_DEST/"

echo "🛠   Building Zellij statusbar... done."

# Zellij runner
echo
echo "🛠   Building Zellij runner..."

ZELLIJ_RUNNER_SRC="$DOTFILES_BIN/zellij/runner"

cd $ZELLIJ_RUNNER_SRC
cargo install --locked --path .

cd $DOTFILES

echo "🛠   Building Zellij runner... done."

# Finally, ensuring .hushlogin exists to get rid of "Last login..." message
echo
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin..."
touch "$HOME/.hushlogin"
echo "📋  Ensuring .hushlogin: $HOME/.hushlogin... done."

# Before exiting, let's restart the shell to get all the new goodies.
# Since I can run the install script from either bash/zsh or nu shell,
# I set the $PSHELL variable on the call site to let this script know
# which shell to restart.
PSHELL="${PSHELL:-}"

echo
if [[ -n $PSHELL ]]; then
    case $PSHELL in
        *bash)
            echo "🚀  All done. Restarting $PSHELL shell."
            exec bash -l
            ;;
        *zsh)
            echo "🚀  All done. Restarting $PSHELL shell."
            exec zsh -l
            ;;
        *nu)
            echo "🚀  All done. Restarting $PSHELL shell."
            exec nu
            ;;
        *)
            echo "❕  All done, but I'm not sure what $PSHELL shell is. Restart this shell manually."
        ;;
    esac
else
    echo "❕  All done, but PSHELL is not set. Restart the shell manually."
fi
