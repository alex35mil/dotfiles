export LANG="en_US.UTF-8"

export EDITOR="nvim"
export VISUAL="$EDITOR"

export TERM="xterm-256color"

export CLICOLOR="1"
export LSCOLORS="gxfxcxdxbxegedabagacad"

export DISABLE_AUTO_TITLE="true"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export DEVBOX_PROFILE="$XDG_DATA_HOME/devbox/global/default/.devbox/virtenv/.wrappers"

SWIFT_PATH="/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin"
NPM_PATH="$HOME/.npm-global/bin"

export PATH="$SWIFT_PATH:$NPM_PATH:$PATH"
