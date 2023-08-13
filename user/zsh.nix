lib:

{
  enable = true;

  autocd = true;
  enableAutosuggestions = true;
  enableCompletion = true;

  history = {
    path = "$HOME/.zsh_history";
    save = 10000;
    size = 10000;
    share = true;
  };

  initExtra = ''
    ${builtins.readFile ./zsh/init.sh}
    ${builtins.readFile ./zsh/functions.sh}
  '';

  shellAliases = import ./zsh/aliases.nix;
  sessionVariables = import ./zsh/variables.nix lib;
}
