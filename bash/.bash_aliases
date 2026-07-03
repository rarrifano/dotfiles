# ~/.bash_aliases — sourced by .bashrc

# Editor shortcuts
if command -v nvim &>/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
  alias v='nvim'
  alias vi='nvim'
  alias vim='nvim'
else
  export EDITOR='vi'
  export VISUAL='vi'
  alias v='vi'
  alias vim='vi'
fi

# Git
alias g='git'
alias gs='git status -sb'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

# GTD Taskwarrior
alias t='task'
alias ti='task inbox'
alias ta='task add'
alias tt='task annotate'
alias tm='task modify'
alias td='task done'
alias tn='task next'
alias tw='task wait'
alias tp='task +project list'
alias tdy='task end:yesterday completed'                                                              # done yesterday
alias tdt='task "end.after:$(date +%Y-%m-%dT00:00:00)" completed'                                    # done today
alias tdw='task "end.after:$(date -d "last monday" +%Y-%m-%dT00:00:00 2>/dev/null || date -v-monday +%Y-%m-%dT00:00:00)" completed'  # done this week (Mon–today)

# kubectl completion for k alias — load kubectl completion then bind to k
if command -v kubectl &>/dev/null; then
  source <(kubectl completion bash)
  complete -o default -o nospace -F __start_kubectl k
fi

# terraform completion for tf alias
if command -v terraform &>/dev/null; then
  complete -C terraform tf
fi
an() {
  local file="${HOME}/ntb/scratch-$(date +%Y%m%d).md"
  if [[ $# -eq 0 ]]; then
    "${EDITOR:-vi}" "$file"
  else
    mkdir -p "$(dirname "$file")"
    echo "$*" >>"$file"
  fi
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
alias ..='cd ..'
alias cls='clear'
alias dnuke='docker system prune -f'
alias h='history'
alias hg='history | grep'
alias jq='jq --tab'
alias k='kubectl'
alias la='ls -lhAF'
alias ll='ls -lhF'
alias myip='curl -s https://ifconfig.me && echo'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.bashrc'
alias tf='terraform'
