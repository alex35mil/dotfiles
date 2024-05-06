export LANG="en_US.UTF-8"

export TERM="xterm-256color"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export DEVBOX_PROFILE="$DEVBOX_PROJECT_ROOT/.devbox/virtenv/.wrappers"

export PRETTIERD_DEFAULT_CONFIG="$XDG_CONFIG_HOME/prettier.yml"

SWIFT_BIN_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
NPM_BIN_PATH="$HOME/.npm-global/bin"

export PATH="$SWIFT_BIN_PATH:$NPM_BIN_PATH:$PATH"

export LD_LIBRARY_PATH="$DEVBOX_PACKAGES_DIR/lib:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH"

# if interactive shell
if [[ $- == *i* ]]; then
    export EDITOR="nvim"
    export VISUAL="$EDITOR"

    export CLICOLOR="1"
    export LSCOLORS="gxfxcxdxbxegedabagacad"

    export DISABLE_AUTO_TITLE="true"
fi
