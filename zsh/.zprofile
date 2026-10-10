#!/bin/zsh

# =============================================================================
# Login shell environment
# Runs after /etc/zprofile (path_helper), so PATH order set here is kept.
# Non-login shells inherit these exports from their parent process.
# =============================================================================
[[ -f "$HOME/.shell_env" ]] && source "$HOME/.shell_env"

# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.
