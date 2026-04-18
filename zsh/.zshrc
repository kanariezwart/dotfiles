#!/bin/zsh

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Environment
# =============================================================================
[[ -f "$HOME/.shell_env" ]] && source "$HOME/.shell_env"

# $OSTYPE is een ingebouwde zsh variabele – geen subshell fork nodig zoals bij $(uname)
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

setopt EXTENDED_HISTORY         # Sla timestamp + duur op: ":start:elapsed;command"
setopt SHARE_HISTORY            # Deel history tussen alle sessies (impliceert INC_APPEND)
setopt HIST_EXPIRE_DUPS_FIRST   # Verwijder duplicaten eerst als history vol is
setopt HIST_IGNORE_DUPS         # Sla geen command op als het identiek is aan het vorige
setopt HIST_IGNORE_ALL_DUPS     # Verwijder oudere duplicaten als een nieuw binnenkomt
setopt HIST_FIND_NO_DUPS        # Toon geen duplicaten bij history-zoekopdrachten
setopt HIST_IGNORE_SPACE        # Sla commands die met spatie beginnen niet op
setopt HIST_SAVE_NO_DUPS        # Schrijf geen duplicaten naar het history-bestand
setopt HIST_REDUCE_BLANKS       # Verwijder overbodige spaties voor opslaan
setopt HIST_FCNTL_LOCK          # Gebruik bestandsvergrendeling bij schrijven naar history

# Deduplicate PATH entries
typeset -U PATH

# =============================================================================
# Oh-my-zsh libraries
# =============================================================================
zcomet load ohmyzsh lib/functions.zsh
zcomet load ohmyzsh lib/git.zsh
zcomet load ohmyzsh lib/correction.zsh
zcomet load ohmyzsh lib/completion.zsh
zcomet load ohmyzsh lib/compfix.zsh
zcomet load ohmyzsh lib/clipboard.zsh
zcomet load ohmyzsh lib/grep.zsh
zcomet load ohmyzsh lib/key-bindings.zsh
zcomet load ohmyzsh lib/termsupport.zsh

# =============================================================================
# Oh-my-zsh plugins
# =============================================================================
zcomet load ohmyzsh plugins/encode64
zcomet load ohmyzsh plugins/extract
zcomet load ohmyzsh plugins/gcloud
zcomet load ohmyzsh plugins/gitfast
zcomet load ohmyzsh plugins/golang
zcomet load ohmyzsh plugins/httpie

zstyle :omz:plugins:ssh-agent agent-forwarding on
zcomet load ohmyzsh plugins/ssh-agent
zcomet load ohmyzsh plugins/gpg-agent

[[ "$OSTYPE" == darwin* ]] && zcomet load ohmyzsh plugins/macos

# =============================================================================
# Externe plugins
# =============================================================================

zcomet load joel-porquet/zsh-dircolors-solarized
zcomet load ael-code/zsh-colored-man-pages

# Auto-completions
zcomet fpath zsh-users/zsh-completions src
[[ -f "$HOME/.docker/completions/_docker" ]] && zcomet snippet ~/.docker/completions/_docker

# Auto-suggesties
zcomet load zsh-users/zsh-autosuggestions

# fzf – vóór syntax-highlighting
zcomet load aloxaf/fzf-tab
zcomet load unixorn/fzf-zsh-plugin

# zsh-syntax-highlighting ALTIJD als allerlaatste plugin
zcomet load zsh-users/zsh-syntax-highlighting

# =============================================================================
# custom functions & aliasses
# =============================================================================
zcomet snippet ~/.zsh/functions.zsh
zcomet snippet ~/.zsh/aliases.zsh

# =============================================================================
# Compinit (always last)
# =============================================================================
zcomet compinit
