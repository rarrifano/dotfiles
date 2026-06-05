# ~/.bash_aliases

# Git Aliases
alias g='git'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'

# Docker Aliases
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dstopa='docker stop $(docker ps -a -q)'
alias drma='docker rm $(docker ps -a -q)'
alias dprune='docker system prune -af --volumes'
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'

# Kubernetes (k8s) Aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployment'
alias kgs='kubectl get service'
alias kall='kubectl get all --all-namespaces'
alias kdesc='kubectl describe'
alias klogs='kubectl logs -f'

# Terraform Aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfo='terraform output'
alias tfv='terraform validate'
