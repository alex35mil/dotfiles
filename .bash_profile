BASH_SOURCES=()

BASH_SOURCES+=~/.shell/.exports           # Shell env vars
BASH_SOURCES+=~/.profile                  # Shell default profile
BASH_SOURCES+=~/.shell/.bash/.completions # Shell completions
BASH_SOURCES+=~/.shell/.bash/.prompts     # Shell prompts
BASH_SOURCES+=~/.shell/.aliases           # Shell aliases
BASH_SOURCES+=~/.shell/.functions         # Shell functions
BASH_SOURCES+=~/.nvm/nvm.sh               # NVM

for file in ${BASH_SOURCES[@]}
do
  [[ -s $file ]] && source $file
done
