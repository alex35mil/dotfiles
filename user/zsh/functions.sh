# `c` with no arguments opens the current directory in VS Code,
# otherwise opens the given location
function c() {
  if [[ $# -eq 0 ]]; then
    code .
  else
    code $@
  fi
}

# `l` with no arguments lists contents of the current directory via `tree`,
# otherwise lists contents of given directory
function l() {
  if [[ $# -eq 0 ]]; then
    tree -a -L 1 .
  else
    tree -a -L 1 $@
  fi
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

# Prints listners on a specific port. E.g. `p 3000`
function p() {
  lsof -n -i:$@ | grep LISTEN
}

# `w` with no arguments lists all shell aliases,
# otherwise lists aliases, that start with the given chars
function w() {
  if [[ $# -eq 0 ]]; then
    alias
  else
    alias | grep "^$@"
  fi
}

# Creates a new directory and enters it
function mkd() {
  mkdir -p $@ && cd $_
}

# Clones git repository and enters it
function gcl() {
  git clone $1 && cd $(basename "$1" .git)
}

# Initializes git repository and creates initial commit
function ginit() {
  mkd && git init && git commit -m "Initial commit" --allow-empty
}

# Prints Docker stuff
function dls() {
  echo "--- Images:\n"
  docker image ls
  echo "\n\n--- Containers:\n"
  docker container ls
  echo "\n\n--- Volumes:\n"
  docker volume ls
  echo "\n\n--- Networks:\n"
  docker network ls
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
