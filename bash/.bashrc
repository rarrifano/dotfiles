# ~/.bashrc

# Non-interactive shell? Exit now.
case $- in
    *i*) ;;
      *) return;;
esac

# History: bigger, no duplicates, append.
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Shell options: update window size, recursive globbing.
shopt -s checkwinsize
shopt -s globstar
set -o vi

# PATH: add local bin directories.
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Integrations: bash completion, lesspipe.
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Aliases: colored ls/grep, shortcuts.
if [ -x /bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(/bin/dircolors -b ~/.dircolors)" || eval "$(/bin/dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Prompt: git-aware, colored.
parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'; }
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
    PS1='\u@\h:\w$(parse_git_branch)\$ '
fi
[ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot) && PS1='($debian_chroot)$PS1'

# Local overrides: aliases, machine-specific settings.
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

export DOCKER_HOST=unix:///run/user/1000/docker.sock
