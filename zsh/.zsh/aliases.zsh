#!/bin/dotfiles

# Get week number
alias week='date +%V'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec $SHELL -l'

# Ring the terminal bell, and put a badge on Terminal.app's Dock icon (useful when executing time-consuming commands)
alias badge='tput bel'

alias ff='find . -type f -name'
alias h='history | grep' # Easy history grep

if [[ "$(uname)" == "Darwin" ]]; then
# shellcheck source=.zsh/aliases-osx.zsh
  source ~/.zsh/aliases-osx.zsh
fi
