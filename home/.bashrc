[[ $- != *i* ]] && return

if ! shopt -q login_shell; then
    source ~/.config/shell/variables.sh
fi
source ~/.config/shell/init.mise.sh

source ~/.config/shell/bash/options.sh
source ~/.config/shell/shortcuts.sh
source ~/.config/shell/init.interactive.sh
