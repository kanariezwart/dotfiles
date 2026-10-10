#!/bin/zsh

# Get week number
alias week='date +%V'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec $SHELL -l'

# Ring the terminal bell, and put a badge on Terminal.app's Dock icon (useful when executing time-consuming commands)
alias badge='tput bel'

alias ff='find . -type f -name'

# GNU ls flags; on macOS `ls` is aliased to gls in aliases-osx.zsh
alias ls='ls --color=auto'
alias ll='ls -lahGFN --group-directories-first'

if [[ "$OSTYPE" == darwin* ]]; then
# shellcheck source=.zsh/aliases-osx.zsh
  source ~/.zsh/aliases-osx.zsh
fi
