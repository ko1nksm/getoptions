#!/bin/sh

# This is YOUR shell script

set -eu

# =========================================================================
# If you want to change the options of this shell script,
# change the option parser definition between @getoptions and @end below.
# -------------------------------------------------------------------------
# @getoptions
parser_definition() {
  setup   REST help:usage -- "Usage: your-script.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    FLAG    -f --flag                 -- "takes no arguments"
  param   PARAM   -p --param                -- "takes one argument"
  option  OPTION  -o --option on:"default"  -- "takes one optional argument"
  disp    :usage  -h --help
  disp    VERSION    --version
}
# @end
# =========================================================================


# =========================================================================
# The code between @gengetoptionbs and @end below is regenerated by
#   gengetoptions embed --overwrite your-script.sh
# -------------------------------------------------------------------------
# @gengetoptions parser -i --shellcheck parser_definition parse
# Generated by getoptions (BEGIN)
# URL: https://github.com/ko1nksm/getoptions (v3.3.1)
FLAG=''
PARAM=''
OPTION=''
REST=''
# shellcheck disable=SC2004,SC2034,SC2145,SC2194
parse() {
  OPTIND=$(($#+1))
  while OPTARG= && [ "${REST}" != x ] && [ $# -gt 0 ]; do
    case $1 in
      --?*=*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}
        ;;
      --no-*|--without-*) unset OPTARG ;;
      -[po]?*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}"' ${1+'"$@"'}
        ;;
      -[fh]?*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" -"${OPTARG#??}"' ${1+'"$@"'}
        [ "$2" = -- ] && set -- "$1" unknown -- && REST=x; OPTARG= ;;
    esac
    case $1 in
      '-f'|'--flag')
        [ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break
        eval '[ ${OPTARG+x} ] &&:' && OPTARG='1' || OPTARG=''
        FLAG="$OPTARG"
        ;;
      '-p'|'--param')
        [ $# -le 1 ] && set "required" "$1" && break
        OPTARG=$2
        PARAM="$OPTARG"
        shift ;;
      '-o'|'--option')
        set -- "$1" "$@"
        [ ${OPTARG+x} ] && {
          case $1 in --no-*|--without-*) set "noarg" "${1%%\=*}"; break; esac
          [ "${OPTARG:-}" ] && { shift; OPTARG=$2; } || OPTARG='default'
        } || OPTARG=''
        OPTION="$OPTARG"
        shift ;;
      '-h'|'--help')
        usage
        exit 0 ;;
      '--version')
        echo "${VERSION}"
        exit 0 ;;
      --)
        shift
        while [ $# -gt 0 ]; do
          REST="${REST} \"\${$(($OPTIND-$#))}\""
          shift
        done
        break ;;
      [-]?*) set "unknown" "$1"; break ;;
      *)
        REST="${REST} \"\${$(($OPTIND-$#))}\""
    esac
    shift
  done
  [ $# -eq 0 ] && { OPTIND=1; unset OPTARG; return 0; }
  case $1 in
    unknown) set "Unrecognized option: $2" "$@" ;;
    noarg) set "Does not allow an argument: $2" "$@" ;;
    required) set "Requires an argument: $2" "$@" ;;
    pattern:*) set "Does not match the pattern (${1#*:}): $2" "$@" ;;
    notcmd) set "Not a command: $2" "$@" ;;
    *) set "Validation error ($1): $2" "$@"
  esac
  echo "$1" >&2
  exit 1
}
usage() {
cat<<'GETOPTIONSHERE'
Usage: your-script.sh [options]... [arguments]...

Options:
  -f, --flag                  takes no arguments
  -p, --param PARAM           takes one argument
  -o, --option[=OPTION]       takes one optional argument
  -h, --help                  
      --version               
GETOPTIONSHERE
}
# Generated by getoptions (END)
# @end
# =========================================================================

# Below this line, you are free to write your own code.
parse "$@"
eval "set -- $REST"

echo "FLAG: $FLAG, PARAM: $PARAM, OPTION: $OPTION"
printf '%s\n' "$@" # rest arguments
