export LANG="en_US.UTF-8"

export TERM="xterm-256color"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export HOMEBREW_PREFIX="/opt/homebrew"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"

export PI_CODING_AGENT_DIR="$XDG_CONFIG_HOME/pi/agent"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

export PRETTIERD_DEFAULT_CONFIG="$XDG_CONFIG_HOME/prettier.yml"

SWIFT_BIN_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
GO_BIN_PATH="$HOME/go/bin"
MOONBIT_BIN_PATH="$HOME/.moon/bin"
OBSIDIAN_PATH="/Applications/Obsidian.app/Contents/MacOS"

if [[ -n "${ZSH_VERSION:-}" ]]; then
    typeset -U path
fi

export PATH="$HOME/.local/bin:$SWIFT_BIN_PATH:$GO_BIN_PATH:$MOONBIT_BIN_PATH:$OBSIDIAN_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# if interactive shell
if [[ $- == *i* ]]; then
    export EDITOR="nvim"
    export TERMINAL="ghostty"
    export VISUAL="$EDITOR"

    export CLICOLOR="1"
    export LSCOLORS="gxfxcxdxbxegedabagacad"

    export DISABLE_AUTO_TITLE="true"
fi

source "$XDG_CONFIG_HOME/shell/secrets.sh"
source "$XDG_CONFIG_HOME/shell/apps/_.sh"
