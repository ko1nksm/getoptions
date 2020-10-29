#!/bin/sh

set -eu

# shellcheck disable=SC2034
VERSION=0.1

. ./lib/getoptions.sh
. ./lib/getoptions_help.sh

parser_definition() {
  setup   REST plus:true help:usage -- "Usage: ${2##*/} [options...] [arguments...]"
  msg -- '' 'getoptions sample' ''
  msg -- 'Options:'
  flag    FLAG    -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
  flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
  param   PARAM   -p    --param     pattern:"foo | bar"     -- "accepts --param value / --param=value"
  option  OPTION  -o    --option    on:"default"            -- "accepts -ovalue / --option=value"
  disp    :usage  -h    --help
  disp    VERSION       --version
}

number() { case $OPTARG in (*[!0-9]*) return 1; esac; }

getoptions parser_definition parse "$0"
