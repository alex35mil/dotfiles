if [[ -n "$ZSH_VERSION" ]]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
elif [[ -n "$BASH_VERSION" ]]; then
    eval "$($HOME/.local/bin/mise activate bash)"
fi
