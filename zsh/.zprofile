#!/bin/zsh

# =============================================================================
# Login shell environment
# Runs after /etc/zprofile (path_helper), so PATH order set here is kept.
# Non-login shells inherit these exports from their parent process.
# =============================================================================

# Homebrew on Apple Silicon lives in /opt/homebrew, which macOS doesn't put on
# PATH (on Intel it's /usr/local/bin, which is). Before .shell_env: that uses
# brew-installed tools such as vivid and fzf.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -f "$HOME/.shell_env" ]] && source "$HOME/.shell_env"

# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.
