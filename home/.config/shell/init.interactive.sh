# Direnv
if [[ -n "$ZSH_VERSION" ]]; then
    eval "$(direnv hook zsh)"
elif [[ -n "$BASH_VERSION" ]]; then
    eval "$(direnv hook bash)"
fi

# Starship
if [[ -n "$ZSH_VERSION" ]]; then
    eval "$(starship init zsh)"
elif [[ -n "$BASH_VERSION" ]]; then
    eval "$(starship init bash)"
fi
