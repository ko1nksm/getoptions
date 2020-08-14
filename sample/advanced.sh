#!/bin/sh

set -eu

. ./getoptions.sh

# shellcheck disable=SC2034
VERSION=0.1

# shellcheck disable=SC1083,SC2016
parser_definition() {
  setup restargs:ARGS error:error on:1 off: export:true -- \
    "Usage: ${2##*/} [options] [arguments...]" '' 'getoptions sample' ''
  flag    FLAG_A -a --flag-a on:1 off: init:= export:
  flag    FLAG_B -b +b --{no-}flag-b on:ON off:OFF init:@off
  flag    FLAG_C -c +c --{no-}flag-c on:1 off:0 init:@unset
  flag    VERBOSE -v +v --{no-}verbose counter:true init:=0
  param   PARAM -p --param init:="default"
  param   NUMBER -n --number validate:number
  param   RANGE -r --range validate:'range 10 100'
  param   :multiple -m --multiple init:'MULTIPLE=""'
  option  OPTION -o --option default:"omission value"
  disp    :'getoptions parser_definition parse "$0"' --generate
  disp    :usage -h --help
  disp    VERSION --version
}

abort() { echo "$@" >&2; exit 1; }

error() {
  case $1 in
    unknown) abort "$@" ;;
    *) return 1 ;; # Display default error
  esac
}

number() {
  case $OPTARG in (*[!0-9]*)
    abort "'$OPTARG' is not a number"
  esac
}

range() {
  number
  if [ "$OPTARG" -lt "$1" ] || [ "$2" -lt "$OPTARG" ]; then
    abort "out of range ($1 <= VALUE <= $2)"
  fi
}

multiple() {
  MULTIPLE="${MULTIPLE}${MULTIPLE:+,}${OPTARG}"
}

eval "$(getoptions parser_definition parse "$0")"
eval "$(getoptions_help parser_definition usage "$0")"
parse "$@"
eval "set -- $ARGS"

echo "FLAG_A: $FLAG_A"
echo "FLAG_B: $FLAG_B"
if [ ${FLAG_C+x} ]; then
  echo "FLAG_C: $FLAG_C"
else
  echo "FLAG_C: <unset>"
fi
echo "VERBOSE: $VERBOSE"
echo "PARAM: $PARAM"
echo "NUMBER: $NUMBER"
echo "RANGE: $RANGE"
echo "MULTIPLE: $MULTIPLE"
echo "OPTION: $OPTION"
i=0
while [ $# -gt 0 ] && i=$((i + 1)); do
  echo "$i: $1"
  shift
done
