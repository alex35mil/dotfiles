# Login shells load their environment after macOS's PATH setup in .zprofile.
if [[ ! -o login ]]; then
    source ~/.config/shell/variables.sh

    if [[ ! -o interactive ]]; then
        source ~/.config/shell/init.mise.sh
    fi
fi
