#!/bin/sh
# shellcheck disable=SC2034

set -eu

VERSION=$(cat VERSION)
URL="https://github.com/ko1nksm/getoptions"
LICENSE="Creative Commons Zero v1.0 Universal"

while IFS= read -r line; do
	case $line in
		*"# @OUTPUT-BEGIN") echo "\"\$@\" '" ;;
		*"# @OUTPUT-END") echo "'" ;;
		*"# @INCLUDE-FILE") eval "$line" | sed "s/'/'\\\\''/g" ;;
		*"# @VAR")
			var=${line%%\=*} value=""
			eval "value=\$$var"
			printf '%s="%s"\n' "$var" "$value"
			;;
		*) printf '%s\n' "$line" ;;
	esac
done
