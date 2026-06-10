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
# PATH: add local bin directories.
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Go configuration
[ -d /usr/local/go/bin ] && PATH="/usr/local/go/bin:$PATH"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
[ -d "${GOPATH}/bin" ] && PATH="${GOPATH}/bin:$PATH"

# Default Editors for C-x C-e and system utilities
export EDITOR="vi"
export VISUAL="vi"

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
# 4. System Integrations & Completions
# ==========================================
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ==========================================
# 5. Prompt & Terminal Appearance
# ==========================================
parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'; }
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\[\033[00;33m\]$(_task_inbox_count)\[\033[00m\]\$ '
else
    PS1='\u@\h:\w$(parse_git_branch)$(_task_inbox_count)\$ '
fi
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
# 8. Sourcing Local Files & Customizations
# ==========================================
# These are sourced at the end so they can override settings above.
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
