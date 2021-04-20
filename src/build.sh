#!/bin/sh
# shellcheck disable=SC2016

set -eu

while IFS= read -r line; do
	case $line in
		*"# @INCLUDE-FILE")
			printf '\tputlines \\\n'
			eval "$line" | sed "s/'/'\\\\''/g; s/^/\t\t'/; s/$/' \\\\/"
			echo
			;;
		*) printf '%s\n' "$line" ;;
	esac
done
