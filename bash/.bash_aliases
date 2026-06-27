# ~/.bash_aliases — sourced by .bashrc

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias ~='cd ~'

# Listing (ls / eza)
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lha --group-directories-first --git'
  alias lt='eza --tree --level=2'
else
  # fallback
  alias ll='ls -lhF'
  alias la='ls -lhAF'
  alias lt='find . -maxdepth 2 | sort'
fi

# Safety nets
alias mkdir='mkdir -pv'

# Disk / system
alias df='df -h'
alias du='du -h'
alias duh='du -sh *'
alias free='free -h'
alias psg='ps aux | grep -v grep | grep'
alias ports='ss -tulnp'

# Editor shortcuts
if command -v nvim &>/dev/null; then
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
else
  alias v='vi'
  alias vim='vi'
fi

# Git
alias g='git'
alias gs='git status -sb'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan -out=.tfplan'
alias tfa='terraform apply .tfplan'
alias tfd='terraform destroy'
alias tff='terraform fmt -recursive'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfs='terraform state'
alias tfw='terraform workspace'

# Kubernetes
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deployment'
alias kgi='kubectl get ingress'
alias ktop='kubectl top pods'

# Docker / Podman
alias dk='docker'
alias dkp='docker ps'
alias dkpa='docker ps -a'
alias dki='docker images'
alias dkl='docker logs -f'
alias dkex='docker exec -it'
alias dkrm='docker rm'
alias dkrmi='docker rmi'
alias dkprune='docker system prune -f'
alias dkc='docker compose'
alias dkcu='docker compose up -d'
alias dkcd='docker compose down'
alias dkcl='docker compose logs -f'

# GTD — Taskwarrior
ib() { task add project:inbox "$@"; }
alias inbox='task project:inbox list'
alias triage='task project:inbox list'
weekly-review() {
  local since
  since=$(date -d 'last monday' '+%Y-%m-%d' 2>/dev/null || date -v-monday '+%Y-%m-%d')
  local prompt="/weekly-report"
  [[ -n "${1:-}" ]] && prompt="/weekly-report ${1}"
  {
    echo "# Weekly Review Context"
    echo "## Period: ${since} → $(date '+%Y-%m-%d')"
    echo ""
    echo "## Completed tasks"
    task completed end.after:"${since}" export 2>/dev/null \
      | jq -r '.[] | "- [\(.project // "no-project")] \(.description)"' 2>/dev/null \
      || task completed end.after:"${since}" 2>/dev/null
    echo ""
    echo "## Active tasks (review)"
    task review 2>/dev/null || true
  } | pi -p "${prompt}"
}

# pi with mdcat rendering — check at call time so mise shims are already in PATH
pi() {
  if [[ "$*" == *"-p"* || "$*" == *"--print"* ]] && command -v mdcat &>/dev/null; then
    if [[ -t 0 ]]; then
      # stdin is the terminal: close it so pi doesn’t block waiting for piped input
      command pi "$@" </dev/null | mdcat -
    else
      # stdin is already piped (e.g. cat file | pi -p "..."): pass it through
      command pi "$@" | mdcat -
    fi
  else
    command pi "$@"
  fi
}

# Misc utilities
alias path='echo $PATH | tr ":" "\n"'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias myip='curl -s https://ifconfig.me && echo'
alias reload='source ~/.bashrc'
alias cls='clear'
alias h='history'
alias hg='history | grep'
alias jq='jq --tab'
