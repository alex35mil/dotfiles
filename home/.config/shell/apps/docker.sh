alias d="docker "
alias dps="docker ps "
alias dpsa="docker ps -a "
alias dsa="docker container stop $(docker ps -a -q)"
alias dimg="docker image "
alias dimgls="docker image ls "
alias dimgrm="docker image rm "
alias dimgpr="docker image prune "
alias dct="docker container "
alias dctls="docker container ls "
alias dctrm="docker container rm "
alias dctpr="docker container prune "
alias dvol="docker volume "
alias dvolls="docker volume ls "
alias dvolrm="docker volume rm "
alias dvolpr="docker volume prune "
alias dnet="docker network "
alias dnetls="docker network ls "
alias dnetrm="docker network rm "
alias dnetpr="docker network prune "
alias dspr="docker system prune "
alias dspra="docker system prune -a"
alias dc="docker compose "
alias dcup="docker compose up"
alias dcupb="docker compose up --build"

# Prints Docker stats
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
