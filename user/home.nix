{ lib, pkgs, ... }:

{
  home.username = "Alex";
  home.homeDirectory = "/Users/Alex";

  home.stateVersion = "22.05";

  home.packages = import ./packages.nix pkgs;

  home.file = import ./files.nix;

  programs.home-manager = { enable = true; };

  programs.zsh = import ./config/zsh.nix lib;
  programs.git = import ./config/git.nix;
  programs.neovim = import ./config/neovim.nix;
  programs.direnv = import ./config/direnv.nix;
  programs.starship = import ./config/starship.nix;
}
