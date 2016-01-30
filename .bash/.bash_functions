# Create a new directory and enter it
function mkd() {
  mkdir -p $@ && cd $_
}

# `a` with no arguments opens the current directory in Atom Editor,
# otherwise opens the given location
function a() {
  if [ $# -eq 0 ]; then
    atom .
  else
    atom $@
  fi
}

# `v` with no arguments opens the current directory in Vim,
# otherwise opens the given location
# Currently handled by NERDTree
# function v() {
#   if [ $# -eq 0 ]; then
#     vim .
#   else
#     vim $@
#   fi
# }

# `dir` with no arguments lists contents of the current directory via `tree`,
# otherwise lists directory tree given depth
function dir() {
  if [ $# -eq 0 ]; then
    tree -a -L 1
  else
    tree -a -L $@
  fi
}

# Scaffold specified project or layout in iTerm
function run() {
  local NPM_MODULES="/usr/local/lib/node_modules"
  local ITERM="$HOME/.iterm/layouts"

  if [ $# -eq 2 ]; then
    local TEMPLATE=$1
    local APP=$2
    local TEMPLATE_FILE="$ITERM/templates/$TEMPLATE.js"
    if [ -f $TEMPLATE_FILE ]; then
      NODE_PATH=$NPM_MODULES node $TEMPLATE_FILE $APP
      itermocil --here $APP
    else
      echo "Can't find template file with name $TEMPLATE"
    fi

  elif [ $# -eq 1 ]; then
    local PROJECT_FILE="$ITERM/projects/$@"
    if [ -r $PROJECT_FILE ] && [ -f $PROJECT_FILE ]; then
      IFS=$'\n' read -d '' -r -a params < $PROJECT_FILE
      local TEMPLATE=${params[0]}
      local APP=${params[1]}
      local LOCATION=${params[2]}
      local TEMPLATE_FILE="$ITERM/templates/$TEMPLATE.js"
      if [ -f $TEMPLATE_FILE ]; then
        NODE_PATH=$NPM_MODULES node $TEMPLATE_FILE $APP $LOCATION
        itermocil --here $APP
      else
        echo "Can't find template file with name $TEMPLATE"
      fi
    else
      echo "Can't find project file with name $@"
    fi

  fi
}
