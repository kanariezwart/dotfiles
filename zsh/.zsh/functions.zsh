#!/bin/dotfiles

# Simple calculator
function calc() {
  local result=""
  result="$(printf 'scale=10;%s\n' "$*" | bc --mathlib | tr -d '\\\n')"
  #                       └─ default (when `--mathlib` is used) is 20
  #
  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    printf '%s' "$result" |
    sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
        -e 's/^-\./-0./'      `# add "0" for cases like "-.5"` \
        -e 's/0*$//;s/\.$//'   # remove trailing zeros
  else
    printf '%s' "$result"
  fi
  printf "\n"
}

# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$@" || return 1
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
  local tmpFile="${*%/}.tar"
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

  local size
  size=$(stat -c%s "${tmpFile}" 2>/dev/null || stat -f%z "${tmpFile}" 2>/dev/null)

  local cmd=""
  if (( size < 52428800 )) && hash zopfli 2>/dev/null; then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli"
  elif hash pigz 2>/dev/null; then
    cmd="pigz"
  else
    cmd="gzip"
  fi

  echo "Compressing .tar using \`${cmd}\`…"
  "${cmd}" -v "${tmpFile}" || return 1
  [[ -f "${tmpFile}" ]] && rm "${tmpFile}"
  echo "${tmpFile}.gz created successfully."
}

# Determine size of a file or total size of a directory
function fs() {
  local arg
  du -b /dev/null &>/dev/null && arg=-sbh || arg=-sh
  du $arg -- "${@:-.}"
}

# Run `dig` and display the most useful info
function digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# UTF-8-encode a string of Unicode symbols
function escape() {
  # shellcheck disable=SC2046
  printf "\\\x%s" $(printf '%s' "$@" | xxd -p -c1 -u)
  # print a newline unless we're piping the output to another program
  if [ -t 1 ]; then
    echo "" # newline
  fi
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
  if [ -z "${1}" ]; then
    echo "ERROR: No domain specified."
    return 1
  fi

  local domain="${1}"
  echo "Testing ${domain}…"
  echo "" # newline

  local tmp
  tmp=$(echo -e "GET / HTTP/1.0\nEOT" | openssl s_client -connect "${domain}:443" 2>&1)

  if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
    local certText
    certText=$(echo "${tmp}" | openssl x509 -text -certopt \
      "no_header, no_serial, no_version, no_signame, no_validity, no_issuer, no_pubkey, no_sigdump, no_aux")
    echo "Common Name:"
    echo "" # newline
    echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//"
    echo "" # newline
    echo "Subject Alternative Name(s):"
    echo "" # newline
    echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
      | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
    return 0
  else
    echo "ERROR: Certificate not found."
    return 1
  fi
}

# Update zcomet plugins
function update_zcomet() {
  zcomet self-update
  zcomet update
  exec zsh
}

# Update Homebrew and all packages (macOS only)
function update_brew() {
  brew update \
    && brew upgrade \
    && brew cu -avyf \
    && brew cleanup \
    && brew autoremove
}

# Full system update: macOS software + brew + zcomet
function update() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sudo softwareupdate -i -a
    update_brew
  fi
  update_zcomet
}

# Get public IP or resolve a domain
function ip() {
  if [[ -n "$1" ]]; then
    dig +short "$1" | tail -n 1
  else
    curl -s ipinfo.io/ip && echo
  fi
}
