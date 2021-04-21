#!/bin/sh

set -eu

# shellcheck disable=SC2034
VERSION=0.1

# shellcheck disable=SC1083
parser_definition() {
	setup   REST help:usage abbr:true -- \
		"Usage: ${2##*/} [global options...] [command] [options...] [arguments...]"
	msg -- '' 'getoptions subcommand example' ''
	msg -- 'Options:'
	flag    GLOBAL  -g --global    -- "global flag"
	disp    :usage  -h --help
	disp    VERSION    --version

	msg -- '' 'Commands:'
	cmd cmd1 -- "subcommand 1"
	cmd cmd2 -- "subcommand 2"
	cmd cmd3 -- "subcommand 3"
}

# shellcheck disable=SC1083
parser_definition_cmd1() {
	setup   REST help:usage abbr:true -- \
		"Usage: ${2##*/} cmd1 [options...] [arguments...]"
	msg -- '' 'getoptions subcommand example' ''
	msg -- 'Options:'
	flag    FLAG_A  -a --flag-a
	disp    :usage  -h --help
}

# shellcheck disable=SC1083
parser_definition_cmd2() {
	setup   REST help:usage abbr:true -- \
		"Usage: ${2##*/} cmd2 [options...] [arguments...]"
	msg -- '' 'getoptions subcommand example' ''
	msg -- 'Options:'
	flag    FLAG_B  -b --flag-b
	disp    :usage  -h --help
}

# shellcheck disable=SC1083
parser_definition_cmd3() {
	setup   REST help:usage abbr:true -- \
		"Usage: ${2##*/} cmd3 [options...] [arguments...]"
	msg -- '' 'getoptions subcommand example' ''
	msg -- 'Options:'
	flag    FLAG_C  -c --flag-c
	disp    :usage  -h --help
}

eval "$(getoptions parser_definition parse "$0") exit 1"
parse "$@"
eval "set -- $REST"

if [ $# -gt 0 ]; then
	cmd=$1
	shift
	case $cmd in
		cmd1)
			eval "$(getoptions parser_definition_cmd1 parse "$0")"
			parse "$@"
			eval "set -- $REST"
			echo "FLAG_A: $FLAG_A"
			;;
		cmd2)
			eval "$(getoptions parser_definition_cmd2 parse "$0")"
			parse "$@"
			eval "set -- $REST"
			echo "FLAG_B: $FLAG_B"
			;;
		cmd3)
			eval "$(getoptions parser_definition_cmd3 parse "$0")"
			parse "$@"
			eval "set -- $REST"
			echo "FLAG_C: $FLAG_C"
			;;
		--) # no subcommand, arguments only
	esac
fi

echo "GLOBAL: $GLOBAL"
i=0
while [ $# -gt 0 ] && i=$((i + 1)); do
	echo "$i: $1"
	shift
done
