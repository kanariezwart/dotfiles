#!/bin/zsh

# =============================================================================
# P10k instant prompt – must be first
# =============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Environment
# =============================================================================
[[ -f "$HOME/.shell_env" ]] && source "$HOME/.shell_env"

# $OSTYPE is a built-in zsh variable – no subshell fork needed like $(uname)
if [[ "$OSTYPE" == darwin* ]]; then
  export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
fi

# =============================================================================
# Zcomet bootstrap
# =============================================================================
if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git ${ZDOTDIR:-${HOME}}/.zcomet/bin
fi
source ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh

# =============================================================================
# Prompt (Powerlevel10k)
# =============================================================================
zcomet load romkatv/powerlevel10k
[[ -f "$HOME/.p10k.zsh" ]] && zcomet snippet ~/.p10k.zsh

# =============================================================================
# History
# =============================================================================
export HISTSIZE=1000000
export SAVEHIST=1000000

setopt EXTENDED_HISTORY       # Save timestamp and duration: ":start:elapsed;command"
setopt SHARE_HISTORY          # Share history between all sessions (implies INC_APPEND)
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when history is full
setopt HIST_IGNORE_DUPS       # Don't record a command identical to the previous one
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicates when a new one is added
setopt HIST_FIND_NO_DUPS      # Don't show duplicates in history searches
setopt HIST_IGNORE_SPACE      # Don't record commands starting with a space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicate entries to the history file
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks before recording
setopt HIST_FCNTL_LOCK        # Use file locking when writing to history

setopt CORRECT

# Deduplicate PATH entries
typeset -U PATH

# =============================================================================
# Oh-my-zsh libraries
# =============================================================================
zcomet load ohmyzsh lib/completion.zsh
zcomet load ohmyzsh lib/compfix.zsh
zcomet load ohmyzsh lib/key-bindings.zsh

# =============================================================================
# Oh-my-zsh plugins
# =============================================================================
zcomet load ohmyzsh plugins/encode64
zcomet load ohmyzsh plugins/extract
zcomet load ohmyzsh plugins/gitfast

# =============================================================================
# Oh-my-zsh plugins lazy load
# =============================================================================
zcomet trigger gcloud ohmyzsh plugins/gcloud
zcomet trigger go ohmyzsh plugins/golang
zcomet trigger http ohmyzsh plugins/httpie

zstyle :omz:plugins:ssh-agent agent-forwarding on
zcomet trigger ssh-add ohmyzsh plugins/ssh-agent
zcomet trigger gpg ohmyzsh plugins/gpg-agent

[[ "$OSTYPE" == darwin* ]] && zcomet load ohmyzsh plugins/macos

# =============================================================================
# Other plugins
# =============================================================================

# Colored man pages
zcomet load ael-code/zsh-colored-man-pages

# Auto-completions
zcomet load zsh-users/zsh-completions
[[ -f "$HOME/.docker/completions/_docker" ]] && zcomet snippet ~/.docker/completions/_docker

# Auto-suggestions
zcomet load zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"

# fzf-tab configuration – must be set before loading fzf-tab
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'

# fzf – must be before syntax-highlighting
zcomet load aloxaf/fzf-tab

# fzf key bindings and completions
[[ -f "$FZF_PATH/shell/key-bindings.zsh" ]] && source "$FZF_PATH/shell/key-bindings.zsh"
[[ -f "$FZF_PATH/shell/completion.zsh" ]] && source "$FZF_PATH/shell/completion.zsh"

# zsh-syntax-highlighting ALWAYS last plugin
zcomet load zdharma-continuum/fast-syntax-highlighting

# =============================================================================
# LS_COLORS & completion colors
# =============================================================================
[[ -z "$LS_COLORS" ]] || zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# =============================================================================
# Key bindings
# =============================================================================
# Context-aware history search with arrow keys

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

# Shift + arrow down – fzf history search
bindkey '^[[1;2B' fzf-history-widget

# =============================================================================
# Custom functions & aliases
# =============================================================================
zcomet snippet ~/.zsh/functions.zsh
zcomet snippet ~/.zsh/aliases.zsh

# =============================================================================
# Compinit (always last)
# =============================================================================
zcomet compinit
