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
echo "→ Copying dotfiles and running make stow…"
mkdir -p "$dotfiles"
git -c safe.directory=/src -C /src ls-files -z --cached --others --exclude-standard \
  | tar -C /src --null -T - --ignore-failed-read -cf - 2>/dev/null \
  | tar -C "$dotfiles" -xf -

make -C "$dotfiles" stow >/dev/null

# Linux packages, as a user would install them (output only on failure)
echo "→ Installing Linux packages (make linux)…"
if ! make -C "$dotfiles" linux >/tmp/make-linux.log 2>&1; then
  cat /tmp/make-linux.log >&2
  exit 1
fi

# One-time setup (ssh, timezone, locale), twice: the second run must find
# everything in place and change nothing
echo "→ Running make setup…"
if ! make -C "$dotfiles" setup >/tmp/setup-1.log 2>&1; then
  cat /tmp/setup-1.log >&2
  exit 1
fi
make -C "$dotfiles" setup >/tmp/setup-2.log 2>&1 || { cat /tmp/setup-2.log >&2; exit 1; }

# Run a command in a fully configured interactive login shell (with a pty).
# The timeout keeps a hanging plugin clone from blocking the test forever.
in_zsh() {
  timeout 120 script -qec "zsh -lic '$1'" /dev/null </dev/null 2>&1 | tr -d '\r'
}

# check <expected output> <command>
failed=0
check() {
  local got
  got=$(in_zsh "$2") || true  # judge by output, not exit status
  if [[ "$got" == "$1" ]]; then
    echo "✓ $2"
  else
    echo "✗ $2: expected '$1', got '$got'" >&2
    failed=1
  fi
}

# First start clones zcomet and plugins, and its first prompt fetches p10k's
# gitstatusd. Doing that up front keeps it out of the shell under test.
# It runs in its own pty (script) and draws one prompt before `exit`: an
# interactive zsh on the container's terminal would take over its foreground
# process group, and the next shell would fail with "error on TTY read".
echo "→ First zsh start: cloning zcomet and plugins (~20s)…"
printf 'exit\n' | timeout 300 script -qec "zsh -li" /dev/null >/dev/null 2>&1 || true

case "${1:-test}" in
  test)
    # second run must print nothing but READY (no errors or warnings)
    out=$(in_zsh 'echo READY')
    echo "$out"
    if [[ "$out" == "READY" ]]; then
      echo "✓ zsh starts cleanly"
    else
      echo "✗ unexpected output during zsh startup" >&2
      exit 1
    fi

    # make setup: system state, and a second run that changes nothing
    check_sh() {  # check_sh <expected output> <bash command>
      local got
      got=$(bash -c "$2" 2>&1) || true
      if [[ "$got" == "$1" ]]; then echo "✓ $2"; else echo "✗ $2: expected '$1', got '$got'" >&2; failed=1; fi
    }
    check_sh /usr/share/zoneinfo/Europe/Amsterdam 'readlink /etc/localtime'
    check_sh Europe/Amsterdam 'cat /etc/timezone'
    check_sh en_US.utf8 'locale -a | grep -ix en_US.utf8'
    check_sh LANG=en_US.UTF-8 'grep ^LANG= /etc/default/locale'
    check_sh 'Include config.local' 'head -1 ~/.ssh/config'
    # shellcheck disable=SC2016  # expands in the checked shell, not here
    check_sh '600 600' 'echo $(stat -c %a ~/.ssh/config ~/.ssh/config.local)'
    # second run: every ✓ line reports "already" (nothing changed)
    check_sh 0 'grep "✓" /tmp/setup-2.log | grep -vc already'
    # shells follow the system timezone (no TZ export in .shell_env)
    # shellcheck disable=SC2016  # expands in the checked shell, not here
    check unset 'echo ${TZ:-unset}'
    check Europe/Amsterdam 'date +%Z | grep -qE "^CES?T$" && echo Europe/Amsterdam'

    # functions work and find the tools they need
    check 0.3333333333 'calc 1/3'
    check 1024 'calc 2^10'
    check '\xE2\x82\xAC' 'escape €'
    check /usr/bin/dig 'whence -p dig'
    check /usr/bin/curl 'whence -p curl'
    check /usr/bin/fzf 'whence -p fzf'
    check '"^R" fzf-history-widget' 'bindkey "^R"'
    check "ll='ls -lahGFN --group-directories-first'" 'alias ll'
    check "lg='git lg'" 'alias lg'
    # no COLORTERM in the container, so vivid's 8-bit palette (38;5;…)
    # shellcheck disable=SC2016  # expands inside zsh, not here
    check vivid '[[ $LS_COLORS == *"38;5;"* ]] && echo vivid'
    # ip keeps only the address when dig also returns CNAME/RRSIG lines
    # (stubbed dig: live DNS answers vary per resolver)
    check 93.184.216.34 'dig() { printf "%s\\n" www.example.com. 93.184.216.34 "A 13 2 300 sig"; }; ip example.com'
    exit "$failed"
    ;;
  shell)
    echo "→ Starting zsh (type exit to leave)"
    exec zsh -l
    ;;
  *)
    echo "usage: run-dotfiles [test|shell]" >&2
    exit 2
    ;;
esac
