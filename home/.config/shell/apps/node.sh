export NPM_CONFIG_PREFIX="$HOME/.npm-global"

alias j="npm "
alias js="npm start"
alias jt="npm test"
alias jr="npm run "
alias ji="npm install --save-exact "
alias jid="npm install --save-dev --save-exact "
alias jrm="npm remove --save "
alias jrmd="npm remove --save-dev "
alias jo="npm outdated"
alias jup="ncu --upgrade --interactive --format group"
alias jupw="ncu --workspaces --upgrade --interactive --format group"
alias jlg="npm ls -g --depth=0"
alias jfuck="rm -rf node_modules && npm cache clean && npm install"

alias y="yarn "
alias ys="yarn start "
alias yt="yarn test"
alias yr="yarn run "
alias yi="yarn add --exact "
alias yid="yarn add --dev --exact "
alias yrm="yarn remove "
alias yo="yarn outdated"
alias yup="yarn upgrade-interactive --exact --latest"
alias yar="rm -rf node_modules && yarn"
alias yarr="rm -rf node_modules && yarn cache clean && yarn"
