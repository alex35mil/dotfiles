# ===== Bash

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias -- -="cd -"

alias dev="cd ~/Dev"
alias prj="cd ~/Dev/Projects"
alias lib="cd ~/Dev/Libs"
alias snd="cd ~/Dev/Sandboxes"
alias sys="cd ~/Dev/System"

# Listings
if ls --color > /dev/null 2>&1; then # GNU `ls`
  colorflag="--color"
else                                 # OSX `ls`
  colorflag="-G"
fi

alias lsa="ls -lFa ${colorflag}"
alias lsv="ls -lF ${colorflag}"
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Remove all DS_Store files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"


# ===== Clojure
alias cba="lein cljsbuild auto "
alias cbo="lein cljsbuild once "
alias cs="lein ring server "
alias cr="lein repl"


# ===== Git
alias got="git "
alias get="git "

alias gs="git status "
alias ga="git add "
alias gb="git branch "
alias gc="git commit "
alias gca="git commit --amend --reuse-message=HEAD"
alias gd="git diff "
alias gp="git push "
alias go="git checkout "
alias gu="git pull --rebase --prune"
alias gr="git rebase "
alias gri="git rebase -i "
alias gh="git history"
alias ghg="gh --graph"


# ===== Node
alias ns="npm start"
alias nt="npm test"
alias nrb="npm run build"
alias nrp="npm run prod"
alias nrl="npm run lint"
alias nis="npm install --save "
alias nid="npm install --save-dev "
alias nrs="npm remove --save "
alias nrd="npm remove --save-dev "
alias nsw="npm shrinkwrap "


# ===== Rails
alias rs="rails server "
alias rc="rails console "
alias rg="rails generate "

alias bi="bundle install "

alias rr="rake routes"
alias rdbm="rake db:migrate"


# ===== Ruby
alias rl="rvm list"
alias rlk="rvm list known"

alias gems="gem list"
alias gemi="gem install "
alias gemu="gem uninstall "

alias rgl="rvm gemset list"
alias rgc="rvm gemset create "
alias rgd="rvm gemset delete "
alias rge="rvm gemset empty "
