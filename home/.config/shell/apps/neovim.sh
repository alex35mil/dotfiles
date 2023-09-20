export NEOVIDE_FRAME="buttonless"
export NEOVIDE_MAXIMIZED="true"

alias v="neovide "
alias vcc="rm -rf ~/.cache/nvim/luac/"
alias vsls="ls -1 ~/.local/state/nvim/swap/"

# Removes Neovim swap files: all or of provided project
function vsc() {
    if [ -z "$1" ]; then
        echo "Provide a project path or '!' to remove all swap files"
        return 1
    fi

    SWAPROOT="$HOME/.local/state/nvim/swap/"

    # If the input argument is !, remove all swap files
    if [[ "$1" == "!" ]]; then
        find $SWAPROOT -type f -name "*.sw[klmnop]" -delete
        echo "All swap files deleted"
    else
        SEARCHTERM=$(echo "%Users%Alex%Dev%$1" | tr '/' '%')
        find $SWAPROOT -type f -name "$SEARCHTERM*.sw[klmnop]" -delete
        echo "Swap files for $1 deleted"
    fi
}
