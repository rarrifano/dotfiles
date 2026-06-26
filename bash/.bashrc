# ~/.bashrc

# Interactive Shell Check
case $- in
*i*) ;;
*) return ;;
esac

# XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# PATH: add local bin directories.
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Go configuration
[ -d /usr/local/go/bin ] && PATH="/usr/local/go/bin:$PATH"
export GOPATH="${XDG_DATA_HOME}/go"
[ -d "${GOPATH}/bin" ] && PATH="${GOPATH}/bin:$PATH"

# Default editors — prefer nvim, fall back to vi
if command -v nvim &>/dev/null; then
  export EDITOR="nvim"
  export VISUAL="nvim"
else
  export EDITOR="vi"
  export VISUAL="vi"
fi

# Docker rootless socket
export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"

# Shell options: update window size, recursive globbing.
shopt -s checkwinsize
shopt -s globstar

# History: bigger, no duplicates, append.
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=50000
HISTFILESIZE=100000
export HISTTIMEFORMAT="%F %T "

# 4. System Integrations
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# 5. Prompt & Terminal Appearance
__ps1_git() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

__ps1_build() {
  local exit=$?
  local r='' bold='' ok='' err='' dim='' box=''
  if [ "${TERM:-dumb}" != dumb ] && [ -t 1 ]; then
    r='\[\e[0m\]'
    bold='\[\e[1m\]'
    dim='\[\e[2m\]'
    case "${TERM}" in *256color* | *kitty* | alacritty | xterm-ghostty)
      ok='\[\e[38;5;142m\]'
      err='\[\e[38;5;167m\]'
      box='\[\e[38;5;243m\]'
      alert='\[\e[38;5;208m\]'
      ;;
    *)
      ok='\[\e[32m\]'
      err='\[\e[31m\]'
      box='\[\e[2m\]'
      alert='\[\e[33m\]'
      ;;
    esac
  fi
  local pc
  [ $exit -eq 0 ] && pc="$ok" || pc="$err"
  local prefix=""
  [ -r /etc/debian_chroot ] && prefix="${dim}($(cat /etc/debian_chroot))${r} "
  [ -n "${CONTAINER_ID:-}" ] && prefix="${box}[${CONTAINER_ID}]${r} "
  local branch
  branch=$(__ps1_git)
  local git_part=""
  [ -n "$branch" ] && git_part="${dim}(${branch})${r} "
  local inbox_part=""
  if [ "${__PS1_INBOX_COUNT:-0}" -gt 0 ]; then
    inbox_part="${bold}${alert}[${__PS1_INBOX_COUNT}]${r} "
  fi
  PS1="${prefix}${bold}\W${r} ${git_part}${inbox_part}${pc}\$${r} "
}
# Refresh inbox count at most once every 30 seconds to avoid forking task on
# every prompt render.
__ps1_inbox_refresh() {
  local now
  now=$(date +%s)
  if [ $(( now - ${__PS1_INBOX_TS:-0} )) -ge 30 ]; then
    __PS1_INBOX_COUNT=$(task project:inbox status:pending count 2>/dev/null || echo 0)
    __PS1_INBOX_TS=$now
  fi
}

PROMPT_COMMAND='__ps1_inbox_refresh; __ps1_build'

if [ -x /bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(/bin/dircolors -b ~/.dircolors)" || eval "$(/bin/dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

# podman as docker drop-in
command -v podman &>/dev/null && ! command -v docker &>/dev/null && alias docker='podman'

# Readline Mode
set -o emacs

# Load system completions after PATH and tool managers are ready
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

# These are sourced at the end so they can override settings above.
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# mise — only load if installed
if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
  eval "$(mise completion bash)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
  eval "$("$HOME/.local/bin/mise" completion bash)"
fi

# Key bindings: CTRL-R (history), CTRL-T (files), ALT-C (cd into dir)
# Shell completion: trigger with ** + TAB (e.g. vim **<TAB>)
if command -v fzf &>/dev/null; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] &&
    . /usr/share/doc/fzf/examples/key-bindings.bash
  [ -f /usr/share/bash-completion/completions/fzf ] &&
    . /usr/share/bash-completion/completions/fzf

  # Use fd for fzf file listing if available (respects .gitignore)
  if command -v fdfind &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
  elif command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # Gruvbox-flavoured colour theme
  export FZF_DEFAULT_OPTS='
    --height 40% --layout=reverse --border
    --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374
    --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
    --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'
fi
