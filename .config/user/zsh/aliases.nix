{
  install = "$HOME/Dev/System/dotfiles/install.sh";
  reload = "source $HOME/.zshrc";

  # Nix
  xx = "home-manager switch";
  xl = "home-manager packages";
  xc = "nix-env --delete-generations old && nix-store --gc";
  xs = "nix-env --query --available --attr-path ";
  xu = "nix-channel --update";
  xi = "nix-shell -p nix-info --run 'nix-info -m'";

  # General
  lsa = "ls -lhFaG";
  rmrf = "rm -rf";
  cleanup = "find . -type f -name '*.DS_Store' -ls -delete";

  # Navigation
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";

  dev = "cd ~/Dev";
  pro = "cd ~/Dev/Projects";
  sys = "cd ~/Dev/System";
  libs = "cd ~/Dev/Libs";
  sand = "cd ~/Dev/Sandboxes";
  dots = "cd ~/Dev/System/dotfiles";

  # Network
  hosts = "sudo $EDITOR /etc/hosts";

  ip = "dig +short myip.opendns.com @resolver1.opendns.com";
  localip = "ipconfig getifaddr en0";

  # Docker
  d = "docker ";

  dps = "docker ps ";
  dpsa = "docker ps -a ";
  dsa = "docker container stop $(docker ps -a -q)";

  di = "docker image ";
  dils = "docker image ls ";
  dirm = "docker image rm ";
  dipr = "docker image prune ";

  dct = "docker container ";
  dctls = "docker container ls ";
  dctrm = "docker container rm ";
  dctpr = "docker container prune ";

  dv = "docker volume ";
  dvls = "docker volume ls ";
  dvrm = "docker volume rm ";
  dvpr = "docker volume prune ";

  dn = "docker network ";
  dnls = "docker network ls ";
  dnrm = "docker network rm ";
  dnpr = "docker network prune ";

  dspr = "docker system prune ";
  dspra = "docker system prune -a";

  dc = "docker-compose ";
  dcup = "docker-compose up";
  dcupb = "docker-compose up --build";

  # Git
  g = "git ";
  gs = "git status ";
  ga = "git add ";
  gap = "git add -p ";
  gb = "git branch ";
  gdm = "git dm";
  gc = "git commit ";
  gcm = "git commit -m ";
  gca = "git commit --amend --reuse-message=HEAD";
  gcam = "git commit --amend";
  gcu = "git reset HEAD~";
  gfr = "git checkout HEAD -- ";
  gd = "git diff ";
  gdc = "git diff --cached ";
  gp = "git push ";
  gpf = "git push --force-with-lease";
  gpu = "git push -u origin HEAD";
  gpt = "git push --tags";
  gprq = "git add . && git commit --amend --reuse-message=HEAD && git push --force-with-lease";
  gco = "git checkout ";
  gcob = "git checkout -b ";
  gcom = "git checkout master";
  gup = "git pull --rebase --prune";
  grau = "git remote add upstream ";
  gf = "git fetch ";
  gfu = "git fetch upstream";
  gm = "git merge ";
  gmum = "git merge upstream/master";
  gr = "git rebase ";
  grm = "git rebase master";
  grc = "git rebase --continue";
  gra = "git rebase --abort";
  grs = "git rebase --skip";
  glc = "git diff --name-only --diff-filter=U";
  gri = "git irebase ";
  gcp = "git cherry-pick ";
  gcpc = "git cherry-pick --continue";
  gcpa = "git cherry-pick --abort";
  gcpq = "git cherry-pick --quit";
  grst = "git reset ";
  grsthard = "git reset --hard HEAD";
  gsh = "git stash";
  gshl = "git stash list";
  gshp = "git stash pop ";
  gh = "git history";
  ghg = "gh --graph";
  gt = "git tag ";
  gta = "git tag -a ";
  gsm = "git submodule ";
  gsma = "git submodule add -b master ";
  gsmu = "git submodule update --remote --merge ";
  gpsc = "git push --recurse-submodules=check ";
  gpsd = "git push --recurse-submodules=on-demand ";

  # Digital Ocean
  dio = "doctl ";

  # K8s
  k = "kubectl ";

  # Node
  n = "npm ";
  ns = "npm start";
  nt = "npm test";
  nr = "npm run ";
  ni = "npm install --save-exact ";
  nid = "npm install --save-dev --save-exact ";
  nrm = "npm remove --save ";
  nrmd = "npm remove --save-dev ";
  no = "npm outdated";
  nlg = "npm ls -g --depth=0";
  nfuck = "rm -rf node_modules && npm cache clean && npm install";

  y = "yarn ";
  ys = "yarn start ";
  yt = "yarn test";
  yr = "yarn run ";
  yi = "yarn add --exact ";
  yid = "yarn add --dev --exact ";
  yrm = "yarn remove ";
  yo = "yarn outdated";
  yup = "yarn upgrade-interactive --exact --latest";
  yar = "rm -rf node_modules && yarn";
  yarr = "rm -rf node_modules && yarn cache clean && yarn";

  # Vim
  v = "nvim ";
}
