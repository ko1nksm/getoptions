#!/bin/sh

set -eu

# shellcheck disable=SC2034
VERSION=0.1

. ./getoptions.sh

# shellcheck disable=SC1083,SC2016
parser_definition() {
  setup   REST plus:true -- "Usage: ${2##*/} [options] [arguments...]"
  msg -- '' 'getoptions sample' ''
  msg -- 'Options:'
  flag    FLAG_A  -a                                        -- "message a"
  flag    FLAG_B  -b                                        -- "message b"
  flag    FLAG_F  -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
  flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
  param   PARAM   -p    --param                             -- "accepts --param value / --param=value"
  param   NUMBER  -n    --number    validate:'number "$1"'  -- "accepts only a number value"
  option  OPTION  -o    --option    default:"default"       -- "accepts -ovalue / --option=value"
  disp    :usage  -h    --help
  disp    VERSION       --version
}

abort() { echo "$@" >&2; exit 1; }
number() {
  case $OPTARG in (*[!0-9]*)
    abort "$1: not a number"
  esac
}

eval "$(getoptions parser_definition parse "$0")"         # Define parse() function
eval "$(getoptions_help parser_definition usage "$0")"    # Define usage() function
parse "$@"
eval "set -- $REST" # Reset the positional parameters to exclude options

echo "FLAG_A: $FLAG_A"
echo "FLAG_B: $FLAG_B"
echo "FLAG_F: $FLAG_F"
echo "VERBOSE: $VERBOSE"
echo "PARAM: $PARAM"
echo "NUMBER: $NUMBER"
echo "OPTION: $OPTION"
i=0
while [ $# -gt 0 ] && i=$((i + 1)); do
  echo "$i: $1"
  shift
done
