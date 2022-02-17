#!/bin/zsh

# Clone zcomet if necessary
if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git ${ZDOTDIR:-${HOME}}/.zcomet/bin
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh

TZ='Europe/Amsterdam';
export TZ;
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/Projects/golang
export GOBIN=$GOPATH/bin
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
export PATH=/usr/local/bin:/usr/local/sbin:$GOBIN:$PATH
export GEM_HOME="$HOME/.gem"
export LC_CTYPE="en_US.UTF-8"
export LANG="en_US.UTF-8"

export JAVA_HOME=/usr/local/Cellar/openjdk/17.0.1_1/libexec/openjdk.jdk/Contents/Home

# Load theme
zcomet load romkatv/powerlevel10k


zcomet load ael-code/zsh-colored-man-pages
zcomet load ohmyzsh lib git.zsh
zcomet load ohmyzsh lib correction.zsh      # dont use zsh correction on system commands like sudo
zcomet load ohmyzsh lib completion.zsh		# oh-my-zsh autocomplete behaviour
zcomet load ohmyzsh lib compfix.zsh         # handle completions insecurities (i.e., completion-dependent directories with insecure ownership or permissions)
zcomet load ohmyzsh lib clipboard.zsh       # clipboard config
zcomet load ohmyzsh lib grep.zsh            #
zcomet load ohmyzsh lib history.zsh         # configure history
zcomet load ohmyzsh lib key-bindings.zsh    # fix bind kys
zcomet load ohmyzsh lib spectrum.zsh
zcomet load ohmyzsh lib termsupport.zsh     # iTerm suppport
zcomet load ohmyzsh lib theme-and-appearance.zsh

# plugins for completions
zcomet load ohmyzsh plugins/gitfast
zcomet load ohmyzsh plugins/git
zcomet load ohmyzsh plugins/encode64
zcomet load ohmyzsh plugins/ssh-agent
zcomet load ohmyzsh plugins/gpg-agent
zcomet load ohmyzsh plugins/extract
zcomet load ohmyzsh plugins/httpie
zcomet load ohmyzsh plugins/golang
zcomet load ohmyzsh plugins/gcloud

# auto completions
# zcomet fpath zsh-users/zsh-completions/src

# if platform osx
if [[ "$(uname)" == "Darwin" ]]; then
 zcomet load ohmyzsh plugins/macos
fi

# it is good to load these popular plugins last, and in this order:
zcomet load zsh-users/zsh-syntax-highlighting
zcomet load zsh-users/zsh-autosuggestions

zstyle :omz:plugins:ssh-agent agent-forwarding on

# no place where to put this at the moment
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"
export LS_COLORS="$(vivid generate solarized-dark)"  # fancy colors

# custom functions
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh
#source ~/.zsh/felyx-cli.zsh

# load prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zstyle ':autocomplete:*' default-context history-incremental-search-backward

# Run compinit and compile its cache
zcomet compinit
