if [[ -z "$SHELL_INITIALIZED" ]]; then
    source ~/.config/shell/init.pre.sh
    source ~/.config/shell/variables.sh
fi

source ~/.config/shell/zsh/options.sh
source ~/.config/shell/shortcuts.sh
source ~/.config/shell/apps/_.sh

source ~/.config/shell/init.mise.sh # independent
source ~/.config/shell/init.interactive.sh
