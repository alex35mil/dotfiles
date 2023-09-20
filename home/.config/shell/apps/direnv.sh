case "$SHELL" in
    */zsh)
        eval "$(direnv hook zsh)"
        ;;
    */bash)
        eval "$(direnv hook bash)"
        ;;
esac
