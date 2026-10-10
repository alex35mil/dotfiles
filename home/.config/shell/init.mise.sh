if [[ -n "${ZSH_VERSION:-}" ]]; then
    if [[ $- == *i* ]]; then
        eval "$("$HOME/.local/bin/mise" activate zsh)"
    else
        eval "$("$HOME/.local/bin/mise" env -s zsh)"
    fi
elif [[ -n "${BASH_VERSION:-}" ]]; then
    if [[ $- == *i* ]]; then
        eval "$("$HOME/.local/bin/mise" activate bash)"
    else
        eval "$("$HOME/.local/bin/mise" env -s bash)"
    fi
fi
