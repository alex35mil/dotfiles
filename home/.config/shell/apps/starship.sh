case "$SHELL" in
    */zsh)
        eval "$(starship init zsh)"
        ;;
    */bash)
        eval "$(starship init bash)"
        ;;
esac
