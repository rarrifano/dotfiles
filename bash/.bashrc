# Exit early for non-interactive shells
[[ $- != *i* ]] && return

# History
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# Editor
export EDITOR=vim
export VISUAL=vim

# Better defaults
set -o vi
shopt -s checkwinsize
PROMPT_DIRTRIM=3

_prompt_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    printf '(%s)' "$branch"
}

# Prompt
PS1='\[\e[1;34m\]\w\[\e[0;33m\]$(_prompt_git_branch)\[\e[0m\]\$ '

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate'
alias v='vim'
alias ta='tmux new -A -s main'

# fzf retrobox colorscheme
export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#1c1c1c,spinner:#fabd2f,hl:#83a598 --color=fg:#ebdbb2,header:#83a598,info:#8ec07c,pointer:#fabd2f --color=marker:#fabd2f,fg+:#ebdbb2,prompt:#8ec07c,hl+:#83a598"

# Bash completion
[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Local overrides
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
