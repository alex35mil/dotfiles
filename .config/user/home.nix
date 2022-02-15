{ pkgs, ... }:

{
  home.username = "Alex";
  home.homeDirectory = "/Users/Alex";

  home.stateVersion = "22.05";

  home.packages = import ./packages.nix pkgs;
  home.sessionPath = import ./path.nix;
  home.file = import ./files.nix;
  
  programs.home-manager = { enable = true; };

  programs.zsh = import ./zsh.nix;
  programs.git = import ./git.nix;
  programs.neovim = import ./neovim.nix pkgs;
  programs.direnv = import ./direnv.nix;
}
