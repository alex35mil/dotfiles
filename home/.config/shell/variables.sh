export LANG="en_US.UTF-8"

export TERM="xterm-256color"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export DEVBOX_PROFILE="$XDG_DATA_HOME/devbox/global/default/.devbox/virtenv/.wrappers"

export PRETTIERD_DEFAULT_CONFIG="$XDG_CONFIG_HOME/prettier.yml"

SWIFT_PATH="/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin"
NPM_PATH="$HOME/.npm-global/bin"

export PATH="$SWIFT_PATH:$NPM_PATH:$PATH"

export DYLD_LIBRARY_PATH="$LD_LIBRARY_PATH" # LD_LIBRARY_PATH is set by devbox

# if interactive shell
if [[ $- == *i* ]]; then
    export EDITOR="nvim"
    export VISUAL="$EDITOR"

    export CLICOLOR="1"
    export LSCOLORS="gxfxcxdxbxegedabagacad"

    export DISABLE_AUTO_TITLE="true"
fi
