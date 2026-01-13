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
alias ghist="git history"
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

# Prints stats for tracked files
function git-branch-stat() {
    # If base branch is provided - use it, otherwise auto-detect
    if [ -n "$1" ]; then
        base_branch="$1"
    else
        if git show-ref --verify --quiet refs/heads/main; then
            base_branch="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            base_branch="master"
        else
            echo "Error: No base branch provided and neither 'main' nor 'master' branches exist" >&2
            return 1
        fi
    fi

    # Get stats for tracked files
    tracked_stats=$(git diff --shortstat $base_branch)
    files_changed=$(echo "$tracked_stats" | grep -o '[0-9]\+ file' | grep -o '[0-9]\+' || echo "0")
    insertions=$(echo "$tracked_stats" | grep -o '[0-9]\+ insertion' | grep -o '[0-9]\+' || echo "0")
    deletions=$(echo "$tracked_stats" | grep -o '[0-9]\+ deletion' | grep -o '[0-9]\+' || echo "0")

    # Count untracked files
    untracked_count=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

    # Count deleted files
    deleted_count=$(git diff --diff-filter=D --summary $base_branch | wc -l | tr -d ' ')

    # Total files affected
    total_files=$((files_changed + untracked_count))

    # ANSI color codes
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    echo "∑ Cumulative changes vs $base_branch branch:"
    echo -e "Files: $total_files (${BLUE}$((files_changed - deleted_count)) changed${NC}, ${GREEN}$untracked_count untracked${NC}, ${RED}$deleted_count deleted${NC})"
    echo -e "Lines: ${GREEN}+$insertions${NC} / ${RED}-$deletions${NC}"
}
