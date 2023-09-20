BASH_SOURCES=()

BASH_SOURCES+=~/.config/shell/variables.sh
BASH_SOURCES+=~/.config/shell/bash/options.sh
BASH_SOURCES+=~/.config/shell/shortcuts.sh
BASH_SOURCES+=~/.config/shell/apps/cargo.sh
BASH_SOURCES+=~/.config/shell/apps/devbox.sh
BASH_SOURCES+=~/.config/shell/apps/direnv.sh
BASH_SOURCES+=~/.config/shell/apps/docker.sh
BASH_SOURCES+=~/.config/shell/apps/git.sh
BASH_SOURCES+=~/.config/shell/apps/neovim.sh
BASH_SOURCES+=~/.config/shell/apps/nix.sh
BASH_SOURCES+=~/.config/shell/apps/node.sh
BASH_SOURCES+=~/.config/shell/apps/starship.sh
BASH_SOURCES+=~/.config/shell/apps/zellij.sh

for file in ${BASH_SOURCES[@]}
do
    [[ -s $file ]] && source $file
done
