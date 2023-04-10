{
    ".editorconfig".source = ./cfg/.editorconfig;
    ".config/alacritty/alacritty.yml".source = ./cfg/alacritty/alacritty.yml;
    ".config/lazygit/config.yml".source = ./cfg/lazygit/config.yml;
    ".config/nvim" = {
        source = ./cfg/nvim;
        recursive = true;
    };
    ".config/karabiner/assets/complex_modifications" = {
        source = ./cfg/karabiner/modifications;
        recursive = true;
    };
    ".config/zellij" = {
        source = ./cfg/zellij;
        recursive = true;
    };
}
