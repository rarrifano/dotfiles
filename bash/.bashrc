# ~/.bashrc

# ==========================================
# 1. Interactive Shell Check
# ==========================================
# Non-interactive shell? Exit now.
case $- in
    *i*) ;;
      *) return;;
esac

# ==========================================
# 2. Environment Variables & PATH
# ==========================================
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

# ==========================================
# 3. Shell Options & History
# ==========================================
# Shell options: update window size, recursive globbing.
shopt -s checkwinsize
shopt -s globstar

# History: bigger, no duplicates, append.
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=50000
HISTFILESIZE=100000
export HISTTIMEFORMAT="%F %T "

# ==========================================
# 4. System Integrations
# ==========================================
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ==========================================
# 5. Prompt & Terminal Appearance
# ==========================================
PS1='\$ '
[ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot) && PS1='($debian_chroot)$PS1'

# ==========================================
# 6. Default Aliases & Colors
# ==========================================
if [ -x /bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(/bin/dircolors -b ~/.dircolors)" || eval "$(/bin/dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ==========================================
# 7. Readline Mode
# ==========================================
set -o emacs

# ==========================================
# 8. Completions
# ==========================================
# Load system completions after PATH and tool managers are ready
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

# ==========================================
# 9. Sourcing Local Files & Customizations
# ==========================================
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
