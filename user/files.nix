{
    ".editorconfig".source = ./config/.editorconfig;
    ".config/alacritty/alacritty.yml".source = ./config/alacritty/alacritty.yml;
    ".config/lazygit/config.yml".source = ./config/lazygit/config.yml;
    ".config/nvim" = {
        source = ./config/neovim;
        recursive = true;
    };
    ".config/karabiner/assets/complex_modifications" = {
        source = ./config/karabiner/modifications;
        recursive = true;
    };
    ".config/zellij" = {
        source = ./config/zellij;
        recursive = true;
    };
}
