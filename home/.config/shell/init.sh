# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Mise
case "$SHELL" in
*/zsh)
    eval "$($HOME/.local/bin/mise activate zsh)"
    ;;
*/bash)
    eval "$($HOME/.local/bin/mise activate bash)"
    ;;
esac

# Cargo
source "$HOME/.cargo/env"

# Direnv
case "$SHELL" in
*/zsh)
    eval "$(direnv hook zsh)"
    ;;
*/bash)
    eval "$(direnv hook bash)"
    ;;
esac
