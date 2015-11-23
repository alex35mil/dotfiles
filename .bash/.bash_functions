# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# `a` with no arguments opens the current directory in Atom Editor,
# otherwise opens the given location
function a() {
  if [ $# -eq 0 ]; then
    atom .;
  else
    atom "$@";
  fi;
}

# `v` with no arguments opens the current directory in Vim,
# otherwise opens the given location
function v() {
  if [ $# -eq 0 ]; then
    vim .;
  else
    vim "$@";
  fi;
}

# `dir` with no arguments lists contents of the current directory via `tree`,
# otherwise lists directory tree given depth
function dir() {
  if [ $# -eq 0 ]; then
    tree -L 1;
  else
    tree -L "$@";
  fi;
}
