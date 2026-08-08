# shellcheck shell=bash
[[ $- != *i* ]] && return

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

if command -v nvim &>/dev/null; then
  export EDITOR='nvim'
  export VISUAL='nvim'
  alias vi='nvim'
  alias vim='nvim'
else
  export EDITOR='vi'
  export VISUAL='vi'
  alias vim='vi'
fi

set -o vi

shopt -s checkwinsize globstar histappend

HISTCONTROL=ignorespace:erasedups
HISTSIZE=50000
HISTFILESIZE=100000
HISTTIMEFORMAT="%F %T "

_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  printf ' (%s)' "$branch"
}

PS1='\W\[\e[38;5;243m\]$(_git_branch)\[\e[38;5;142m\] \$\[\e[0m\] '

command -v podman &>/dev/null && ! command -v docker &>/dev/null && alias docker='podman'

alias ll='ls -lah --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
  eval "$(mise completion bash)"
fi

alias z='$EDITOR ~/Documents/journal/$(date +%Y-%m-%d).md'

if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS='--color=spinner:108,hl:214,fg:223,header:245,info:108,pointer:208,marker:142,fg+:223,prompt:208,hl+:208 --height=40% --layout=reverse --border=sharp'

  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
  [ -f /usr/share/bash-completion/completions/fzf ] && . /usr/share/bash-completion/completions/fzf
  # shellcheck source=/dev/null
  [ -f ~/.fzf.bash ] && . ~/.fzf.bash
fi
