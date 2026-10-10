#!/bin/bash
# Entrypoint for the dotfiles test container.
#   run-dotfiles test   stow the dotfiles and smoke test zsh startup
#   run-dotfiles shell  stow the dotfiles and open an interactive login shell
#
# Expects the repo mounted read-only at /src.
set -euo pipefail

dotfiles="$HOME/Projects/system/dotfiles"

# Copy what a fresh clone plus uncommitted changes would contain: tracked and
# untracked-but-not-ignored files. Gitignored *.local files (secrets) stay out.
mkdir -p "$dotfiles"
git -c safe.directory=/src -C /src ls-files -z --cached --others --exclude-standard \
  | tar -C /src --null -T - --ignore-failed-read -cf - 2>/dev/null \
  | tar -C "$dotfiles" -xf -

make -C "$dotfiles" stow >/dev/null

case "${1:-test}" in
  test)
    # first run clones zcomet and plugins
    zsh -lic exit </dev/null >/dev/null 2>&1 || true
    # second run must print nothing but READY (no errors or warnings)
    out=$(script -qec "zsh -lic 'echo READY'" /dev/null </dev/null 2>&1 | tr -d '\r')
    echo "$out"
    if [[ "$out" == "READY" ]]; then
      echo "✓ zsh starts cleanly"
    else
      echo "✗ unexpected output during zsh startup" >&2
      exit 1
    fi
    ;;
  shell)
    exec zsh -l
    ;;
  *)
    echo "usage: run-dotfiles [test|shell]" >&2
    exit 2
    ;;
esac
