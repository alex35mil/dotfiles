# Add `~/bin` to the `$PATH`
export PATH="$PATH:$HOME/bin";

# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile";

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm";

# Load nvm
[ -s "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh";

# Load the shell .dotfiles
for file in ~/.bash/.{bash_prompt,bash_exports,bash_aliases,bash_functions,bash_locals}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Turn on Vi bindings
set -o vi

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
  source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;
