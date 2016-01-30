# Add `~/bin` to the `$PATH`
export PATH="$PATH:$HOME/bin"

# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Load nvm
[ -s "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh"

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
  source "$(brew --prefix)/share/bash-completion/bash_completion"
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for git
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
else
  echo "Can't find git-completion.bash script. Install it to your \$HOME dir"
fi

# Add tab completion for iTerm layouts
complete -W "$(ls ~/.iterm/layouts/templates | sed -e 's/\.[^.]*$//') $(ls ~/.iterm/layouts/projects)" run

# Load the shell .dotfiles
for file in ~/.bash/.{bash_prompt,bash_exports,bash_aliases,bash_functions}; do
  [ -r "$file"  ] && [ -f "$file"  ] && source "$file"
done
unset file

# Turn on Vi bindings
set -o vi
