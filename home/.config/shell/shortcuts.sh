# === General
alias install="PSHELL=zsh $HOME/Dev/dotfiles/script/install.sh"

case "$SHELL" in
    */zsh)
        alias reload="exec zsh -l"
        ;;
    */bash)
        alias reload="exec bash --login"
        ;;
esac

alias c="clear"
alias q="exit"

# === Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias dv="cd ~/Dev"
alias dn="cd ~/Dev/null"
alias icd="cd ~/Library/Mobile\\ Documents/com~apple~CloudDocs"
alias ico="cd ~/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents"

# === Files
alias lsa="ls -lhFaG"
alias rmrf="rm -rf"

# `i` stands for `inspect`.
# With no arguments, it lists contents of the current directory via `tree`.
# If given a directory, it lists contents of that directory via `tree`.
# If given a file, it shows it with `bat`.
function i() {
    # If no argument is provided, use the current directory
    local target="${1:-.}"

    # If target is a directory
    if [[ -d "$target" ]]; then
        tree -a -L 1 "$target"
    # If target is a file
    elif [[ -f "$target" ]]; then
        bat "$target"
    else
        echo "Error: $target is neither a directory nor a file."
    fi
}

# Creates a new directory and enters it
function mkd() {
    mkdir -p $@ && cd $_
}

# `o` with no arguments opens current folder in Finder,
# otherwise selects given item in Finder
function o() {
    if [[ $# -eq 0 ]]; then
        open -R ./$(ls | sort -n | head -1)
    else
        open -R $@
    fi
}

# `cleanup` removes all .DS_Store files and broken symlinks.
# With no arguments it cleans up the current folder,
# otherwise at the provided path.
function cleanup() {
      # If an argument is provided, use it as the target directory
      # otherwise, use the current directory.
      local target_dir="${1:-.}"

      # Remove .DS_Store files
      find "$target_dir" -type f -name '*.DS_Store' -exec echo "Removing: {}" 1>&2 \; -delete

      # Remove broken symlinks
      find "$target_dir" -type l ! -exec test -e {} \; -exec echo "Removing broken symlink: {}" 1>&2 \; -delete
}

# Adds fingerprint to the filename
function fingerprint() {
    local FILENAME=$1
    local HASH=$(shasum -a 256 "$FILENAME" | awk '{print $1}' | xxd -r -p | base64 | head -c 10)

    if [[ $FILENAME == *.* ]]; then
        local NEXT_FILENAME="${FILENAME%.*}-${HASH}.${FILENAME##*.}"
    else
        local NEXT_FILENAME="${FILENAME}-${HASH}"
    fi

    mv "$FILENAME" "$NEXT_FILENAME"

    echo "$NEXT_FILENAME"
}

# === Network
alias hosts="sudo $EDITOR /etc/hosts"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

# Prints listners on a specific port. E.g. `p 3000`
function p() {
    lsof -n -i:$@ | grep LISTEN
}

# Generates a new ssh entity
function gen-ssh() {
    ssh-keygen -f ~/.ssh/$@ -C "$@"
    echo "Host $@" >> ~/.ssh/config
    echo " HostName __IP__" >> ~/.ssh/config
    echo " ForwardAgent yes" >> ~/.ssh/config
    echo " PreferredAuthentications publickey" >> ~/.ssh/config
    echo " IdentityFile ~/.ssh/$@" >> ~/.ssh/config
    echo "" >> ~/.ssh/config
    vim ~/.ssh/config
}

# === Misc
# `w` with no arguments lists all shell aliases,
# otherwise lists aliases, that start with the given chars
function w() {
    if [[ $# -eq 0 ]]; then
        alias
    else
        alias | grep "^$@"
    fi
}

# Prints nice color chart
function colortest() {
    T='ﮊ ﮊ ﮊ'

    echo -e "\n                    40m       41m       42m       43m\
       44m       45m       46m       47m";

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
               '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
               '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
        do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
        done
        echo;
    done
    echo
}
