alias g="git "
alias gs="git status "
alias ga="git add "
alias gap="git add -p "
alias gb="git branch "
alias gdm="git dm"
alias gc="git commit "
alias gcm="git commit -m "
alias gca="git commit --amend --reuse-message=HEAD"
alias gcam="git commit --amend"
alias gcu="git reset HEAD~"
alias gfr="git checkout HEAD -- "
alias gd="git diff "
alias gdc="git diff --cached "
alias gp="git push "
alias gpf="git push --force-with-lease"
alias gpu="git push -u origin HEAD"
alias gpt="git push --tags"
alias gpft="git push --force --tags"
alias gprq="git add . && git commit --amend --reuse-message=HEAD && git push --force-with-lease"
alias gco="git checkout "
alias gcob="git checkout -b "
alias gcom="git checkout master"
alias gup="git pull --rebase --prune"
alias grau="git remote add upstream "
alias gf="git fetch "
alias gfu="git fetch upstream"
alias gm="git merge "
alias gmum="git merge upstream/master"
alias gr="git rebase "
alias grm="git rebase master"
alias grc="git rebase --continue"
alias gra="git rebase --abort"
alias grs="git rebase --skip"
alias glc="git diff --name-only --diff-filter=U"
alias gri="git irebase "
alias gcp="git cherry-pick "
alias gcpc="git cherry-pick --continue"
alias gcpa="git cherry-pick --abort"
alias gcpq="git cherry-pick --quit"
alias grst="git reset "
alias grsthard="git reset --hard HEAD"
alias gsh="git stash"
alias gshl="git stash list"
alias gshp="git stash pop "
alias gh="git history"
alias ghg="gh --graph"
alias gt="git tag "
alias gta="git tag -a "
alias gtf="git tag -f "
alias gsm="git submodule "
alias gsma="git submodule add -b master "
alias gsmu="git submodule update --remote --merge "
alias gpsc="git push --recurse-submodules=check "
alias gpsd="git push --recurse-submodules=on-demand "

# Clones git repository and enters it
function gcl() {
	git clone $1 && cd $(basename "$1" .git)
}

# Initializes git repository and creates initial commit
function ginit() {
	git init && git commit -m "Initial commit" --allow-empty
}