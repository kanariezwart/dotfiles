#!/bin/dotfiles

# Get week number
alias week='date +%V'

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Ring the terminal bell, and put a badge on Terminal.app’s Dock icon (useful when executing time-consuming commands)
alias badge="tput bel"

# Intuitive map function, eg: to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
alias h='history | grep' # Easy history grep
alias ll='gls -lahGFN --group-directories-first --color=tty'
alias ff='find . -type f -name'

# git aliases
alias glg="git log --graph --decorate --oneline --abbrev-commit"
alias glga="glg --all"

alias update_zcomet='zcomet self-update; zcomet update; reload;'
if [[ "$(uname)" == "Darwin" ]]; then
  source ~/.zsh/aliases-osx.zsh
fi