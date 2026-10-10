#!/bin/zsh

# Get week number
alias week='date +%V'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec $SHELL -l'

# Ring the terminal bell, and put a badge on Terminal.app's Dock icon (useful when executing time-consuming commands)
alias badge='tput bel'

alias ff='find . -type f -name'

# git log (the formats are git aliases in .gitconfig, so `git lg` etc. also
# work outside zsh); names as in oh-my-zsh's git plugin
alias lg='git lg'
alias glog='git lg'
alias gloga='git lga'
alias glol='git ll'
alias glola='git lla'
alias glogg='git graph'

# GNU ls flags; on macOS `ls` is aliased to gls in aliases-osx.zsh
alias ls='ls --color=auto'
alias ll='ls -lahGFN --group-directories-first'

# cat with syntax highlighting; when piped, bat behaves like plain cat.
# An alias (not a symlink) so scripts keep using the real cat.
# Debian/Ubuntu install bat as batcat.
if command -v bat >/dev/null; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null; then
  alias cat='batcat --paging=never'
fi

if [[ "$OSTYPE" == darwin* ]]; then
# shellcheck source=.zsh/aliases-osx.zsh
  source ~/.zsh/aliases-osx.zsh
fi
