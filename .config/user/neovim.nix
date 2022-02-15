pkgs:

{
  enable = true;
  
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    nerdtree
    vim-airline

    # Themes
    gruvbox-nvim
    nvim-base16
  ];

  extraConfig = builtins.readFile ./neovim/.nvimrc;
}
