# ~/.bash_aliases — sourced by .bashrc

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
    task completed end.after:"${since}" export 2>/dev/null |
      jq -r '.[] | "- [\(.project // "no-project")] \(.description)"' 2>/dev/null ||
      task completed end.after:"${since}" 2>/dev/null
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
alias week='date +%V'
