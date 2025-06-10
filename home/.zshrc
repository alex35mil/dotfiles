if [[ -z "$SHELL_INITIALIZED" ]]; then
    source ~/.config/shell/init.sh
    source ~/.config/shell/variables.sh
fi

source ~/.config/shell/zsh/options.sh
source ~/.config/shell/shortcuts.sh

source ~/.config/shell/apps/brew.sh
source ~/.config/shell/apps/cargo.sh
source ~/.config/shell/apps/docker.sh
source ~/.config/shell/apps/git.sh
source ~/.config/shell/apps/mise.sh
source ~/.config/shell/apps/neovim.sh
source ~/.config/shell/apps/nix.sh
source ~/.config/shell/apps/node.sh
source ~/.config/shell/apps/starship.sh
source ~/.config/shell/apps/terraform.sh
source ~/.config/shell/apps/zed.sh
source ~/.config/shell/apps/zellij.sh
