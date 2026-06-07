# ~/.bash_aliases

confirm() {
  local prompt=${1:-"Continue?"}
  local reply
  read -r -p "${prompt} [y/N] " reply
  [[ ${reply} =~ ^([yY]|[yY][eE][sS])$ ]]
}

# Git
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gb='git branch'

# Docker
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'

dstopa() {
  local ids
  ids=$(docker ps -aq)
  [ -n "${ids}" ] || { echo "No containers to stop."; return 0; }
  confirm "Stop all Docker containers?" || return 1
  docker stop ${ids}
}

drma() {
  local ids
  ids=$(docker ps -aq)
  [ -n "${ids}" ] || { echo "No containers to remove."; return 0; }
  confirm "Remove all Docker containers?" || return 1
  docker rm ${ids}
}

dprune() {
  confirm "Prune all Docker data, including volumes?" || return 1
  docker system prune -af --volumes
}

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kall='kubectl get all --all-namespaces'
alias kdesc='kubectl describe'
alias klogs='kubectl logs -f'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfv='terraform validate'
alias tfo='terraform output'

tfa() {
  confirm "Run terraform apply${*:+ ${*}}?" || return 1
  terraform apply "$@"
}

tfd() {
  confirm "Run terraform destroy${*:+ ${*}}?" || return 1
  terraform destroy "$@"
}

# Pi
alias fab='pi -p --no-tools --thinking off'
