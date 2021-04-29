#!/bin/sh

set -eu

# shellcheck disable=SC2034
VERSION="0.1"

parser_definition() {
  setup   REST help:usage -- "Usage: example.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    FLAG    -f --flag                 -- "takes no arguments"
  param   PARAM   -p --param                -- "takes one argument"
  option  OPTION  -o --option on:"default"  -- "takes one optional argument"
  disp    :usage  -h --help
  disp    VERSION    --version
}

[ "${GETOPTIONS:-}" ] && return 0

case ${MODE:-command} in
  command | library)
    if [ "${MODE:-}" = "library" ]; then
      # shellcheck disable=SC1091
      . ./getoptions-library.sh
    fi
    eval "$(getoptions parser_definition parse) exit 1" ;;
  parser)
    # shellcheck disable=SC1091
    . ./getoptions-parser.sh ;;
esac

parse "$@"
eval "set -- $REST"

echo "FLAG: $FLAG, PARAM: $PARAM, OPTION: $OPTION"
printf '%s\n' "$@"
