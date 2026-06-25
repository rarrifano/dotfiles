# ~/.bash_aliases

# Git
alias g='git'
alias gs='git status -sb'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

# Misc utilities
alias ..='cd ..'
alias cls='clear'
alias dnuke='docker system prune -f'
alias k='kubectl'
alias la='ls -a'
alias ll='ls -l'
alias n='$EDITOR ~/ntb/$(date +%y%m%d)-scratch.md'
alias r='source ~/.bashrc'
alias t='task'
alias tf='terraform'
alias v='$EDITOR'
alias week='date +%V'
