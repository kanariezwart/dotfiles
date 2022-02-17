#!/bin/dotfiles

# Simple calculator
function calc() {
	local result="";
	result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')";
	#                       └─ default (when `--mathlib` is used) is 20
	#
	if [[ "$result" == *.* ]]; then
		# improve the output for decimal numbers
		printf "$result" |
		sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
		    -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
		    -e 's/0*$//;s/\.$//';  # remove trailing zeros
	else
		printf "$result";
	fi;
	printf "\n";
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$@";
}


# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";
	echo "${tmpFile}.gz created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* *;
	fi;
}


# Run `dig` and display the most useful info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# UTF-8-encode a string of Unicode symbols
function escape() {
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}


# Show all the names (CNs and SANs) listed in the SSL certificate

# for a given domain
function getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
		| openssl s_client -connect "${domain}:443" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_header, no_serial, no_version, \
			no_signame, no_validity, no_issuer, no_pubkey, no_sigdump, no_aux");
			echo "Common Name:";
			echo ""; # newline
			echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//";
			echo ""; # newline
			echo "Subject Alternative Name(s):";
			echo ""; # newline
			echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
				| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
			return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}


extract2 () {
    if [ -f $1 ] ; then
    case $1 in
       *.tar.bz2) tar xvjf $1 ;;
       *.tar.gz) tar xvzf $1 ;;
       *.bz2) bunzip2 $1 ;;
       *.rar) unrar x $1 ;;
       *.gz) gunzip $1 ;;
       *.tar) tar xvf $1 ;;
       *.tbz2) tar xvjf $1 ;;
       *.tgz) tar xvzf $1 ;;
       *.zip) unzip $1 ;;
       *.Z) uncompress $1 ;;
       *.7z) 7z x $1 ;;
       *) echo "don't know how to extract '$1'..." ;;
    esac
    else
      echo "'$1' is not a valid file!"
    fi
}
