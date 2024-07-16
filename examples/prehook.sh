#!/bin/sh

set -eu

PREFIX_VERSION=0.1

# shellcheck disable=SC2145,SC2317
parser_definition() {
	# Append prefix to variable name using prehook
	prefix=$3
	prehook() {
		helper=$1 subject=$2
		shift 2
		case $helper in (flag | param | option)
			case $subject in
				:*) subject="$subject $prefix" ;;
				*) subject="${prefix}_${subject}" ;;
			esac
		esac
		invoke "$helper" "$subject" "$@"
	}

	multi() { param ":multiple $@"; } # custom helper function

	setup   REST help:usage -- \
		"Usage: ${2##*/} [options...] [arguments...]" '' \
		'getoptions extension example' ''
	flag    FLAG      -f  --flag
	param   PARAM     -p  --param
	multi   MULTIPLE  -m  --multiple init:"${3}_MULTIPLE=''"
	disp    :usage    -h  --help
	disp    VERSION   -v  --version
}

multiple() {
	eval "$2_$1=\${$2_$1}\${$2_$1:+,}\${OPTARG}"
}

eval "$(getoptions parser_definition parse "$0" PREFIX) exit 1"
parse "$@"
eval "set -- $REST"

echo "FLAG: $PREFIX_FLAG"
echo "PARAM: $PREFIX_PARAM"
echo "MULTIPLE: $PREFIX_MULTIPLE"
echo "VERSION: $PREFIX_VERSION"

i=0
while [ $# -gt 0 ] && i=$((i + 1)); do
	echo "$i: $1"
	shift
done
