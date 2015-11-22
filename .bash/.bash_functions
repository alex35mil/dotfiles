# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_";
}
