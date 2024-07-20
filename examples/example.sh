#!/bin/sh

set -eu

# shellcheck disable=SC2034
VERSION="0.1"

parser_definition() {
  setup   REST help:usage -- "Usage: example.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    FLAG1   -f --flag1                -- "takes no arguments"
  flag    FLAG2   -g --flag2                -- "takes no arguments"
  flag    FLAG3   -h --flag3                -- "takes no arguments"
  param   PARAM1  -p --param1               -- "takes one argument"
  param   PARAM2  -q --param2               -- "takes one argument"
  param   PARAM3  -r --param3               -- "takes one argument"
  option  OPTION1 -m --option1 on:"default" -- "takes one optional argument"
  option  OPTION2 -n --option2 on:"default" -- "takes one optional argument"
  option  OPTION3 -o --option3 on:"default" -- "takes one optional argument"
  disp    :usage  -h --help
  disp    VERSION    --version
}

[ "${GETOPTIONS:-}" ] && return 0

# The following code is used when called from bench.sh
# shellcheck disable=SC1090
case ${MODE:-command:} in
  command:*)
    eval "$(getoptions parser_definition) exit 1" ;;
  library:*)
    . "${MODE#*:}"
    eval "$(getoptions parser_definition) exit 1" ;;
  generator:*)
    . "${MODE#*:}"
    "$PARSER" "$@"
    eval "set -- $REST"
esac

echo "FLAG1:$FLAG1 FLAG2:$FLAG2 FLAG3:$FLAG3"
echo "PARAM1:$PARAM1 PARAM2:$PARAM2 PARAM3:$PARAM3"
echo "OPTION1:$OPTION1 OPTION2:$OPTION2 OPTION3:$OPTION3"
if [ $# -eq 0 ]; then
  echo "PARAMS: $# (none)"
else
  echo "PARAMS: $#"
  for i in "$@"; do
    printf '%s %s\n' - "$i"
  done
fi
