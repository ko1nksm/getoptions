#!/bin/sh
# shellcheck disable=SC2016,SC2034

set -eu

VERSION="v3.0.0-dev"
URL="https://github.com/ko1nksm/getoptions"
LICENSE="Creative Commons Zero v1.0 Universal"

while IFS= read -r line; do
	case $line in
		*"# @INCLUDE-FILE")
			printf '\t%s \\\n' "putlines"
			eval "$line" | sed "s/'/'\\\\''/g; s/^/\t\t'/; s/$/' \\\\/"
			echo
			;;
		*"# @VAR")
			var=${line%%\=*} value=""
			eval "value=\$$var"
			printf '%s="%s"\n' "$var" "$value"
			;;
		*) printf '%s\n' "$line" ;;
	esac
done
