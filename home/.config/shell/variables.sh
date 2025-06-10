export LANG="en_US.UTF-8"

export TERM="xterm-256color"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export HOMEBREW_BUNDLE_FILE="$HOME/.config/brew/Brewfile"
export HOMEBREW_NO_AUTO_UPDATE=1

export SDKROOT=$(xcrun --show-sdk-path)

SWIFT_BIN_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
GO_BIN_PATH="$(go env GOPATH)/bin"
NPM_BIN_PATH="$HOME/.npm-global/bin"

export PATH="$SWIFT_BIN_PATH:$GO_BIN_PATH:$NPM_BIN_PATH:$PATH"

export PRETTIERD_DEFAULT_CONFIG="$XDG_CONFIG_HOME/prettier.yml"

# if interactive shell
if [[ $- == *i* ]]; then
    export EDITOR="nvim"
    export VISUAL="$EDITOR"

    export CLICOLOR="1"
    export LSCOLORS="gxfxcxdxbxegedabagacad"

    export DISABLE_AUTO_TITLE="true"
fi

source "$HOME/.config/shell/secrets.sh"
