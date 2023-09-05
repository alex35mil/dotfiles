lib:

let
    paths = [
        "/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin" # Swift
        "/usr/local/opt/libpq/bin" # Diesel needs this
        "$HOME/.npm-global/bin" # npm global packages
    ];
    path = lib.concatStringsSep ":" paths;
in
{
  LANG = "en_US.UTF-8";

  PATH = "${path}:$PATH";

  EDITOR = "nvim";
  VISUAL = "$EDITOR";

  TERM = "xterm-256color";

  CLICOLOR = "1";
  LSCOLORS = "gxfxcxdxbxegedabagacad";

  DISABLE_AUTO_TITLE = "true";

  XDG_CONFIG_HOME = "$HOME/.config";

  NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  NEOVIDE_FRAME = "buttonless";
  NEOVIDE_MAXIMIZED="true";

  ZELLIJ_RUNNER_ROOT_DIR = "Dev";
  ZELLIJ_RUNNER_IGNORE_DIRS = "node_modules,target";
  ZELLIJ_RUNNER_MAX_DIRS_DEPTH = "3";
  ZELLIJ_RUNNER_LAYOUTS_DIR = ".config/zellij/layouts";
  ZELLIJ_RUNNER_BANNERS_DIR = ".config/zellij/banners";
}
