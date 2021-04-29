#!/bin/sh

set -eu

VERSION=0.1

# shellcheck disable=SC1083
parser_definition() {
	setup   REST plus:true help:usage abbr:true -- \
		"Usage: ${2##*/} [options...] [arguments...]" ''
	msg -- 'getoptions basic example' ''
	msg -- 'Options:'
	flag    FLAG_A  -a                                        -- "message a"
	flag    FLAG_B  -b                                        -- "message b"
	flag    FLAG_F  -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
	flag    FLAG_W        --with{out}-flag                    -- "expands to ---with-flag and --without-flag"
	flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
	param   PARAM   -p    --param     pattern:"foo | bar"     -- "accepts --param value / --param=value"
	param   NUMBER  -n    --number    validate:number         -- "accepts only a number value"
	option  OPTION  -o    --option    on:"default"            -- "accepts -ovalue / --option=value"
	disp    :usage  -h    --help
	disp    VERSION       --version
}

number() { case $OPTARG in (*[!0-9]*) return 1; esac; }

eval "$(getoptions parser_definition - "$0") exit 1"

echo "FLAG_A: $FLAG_A"
echo "FLAG_B: $FLAG_B"
echo "FLAG_F: $FLAG_F"
echo "FLAG_W: $FLAG_W"
echo "VERBOSE: $VERBOSE"
echo "PARAM: $PARAM"
echo "NUMBER: $NUMBER"
echo "OPTION: $OPTION"
echo "VERSION: $VERSION"
i=0
while [ $# -gt 0 ] && i=$((i + 1)); do
	echo "$i: $1"
	shift
done
