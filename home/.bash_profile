source ~/.config/shell/variables.sh

if [[ $- == *i* ]]; then
    [[ -f ~/.bashrc ]] && source ~/.bashrc
else
    source ~/.config/shell/init.mise.sh
fi
