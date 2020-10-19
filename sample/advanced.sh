#!/bin/sh

set -eu

. ./getoptions.sh
. ./getoptions_help.sh

# shellcheck disable=SC2034
VERSION=0.1

# shellcheck disable=SC1083,SC2016
parser_definition() {
	setup   REST error:error on:1 off: export:true -- \
		"Usage: ${2##*/} [options...] [arguments...]" '' 'getoptions sample' ''
	flag    FLAG_A -a --flag-a on:1 off: init:= export:
	flag    FLAG_B -b +b --{no-}flag-b on:ON off:OFF init:@off
	flag    FLAG_C -c +c --{no-}flag-c on:1 off:0 init:@unset
	flag    VERBOSE -v +v --{no-}verbose counter:true init:=0
	param   PARAM -p --param init:="default"
	param   NUMBER -n --number validate:number
	param   RANGE -r --range validate:'range 10 100'
	param   REGEX --regex validate:'regex "^[1-9][0-9]+$"'
	param   :multiple -m --multiple init:'MULTIPLE=""'
	param   :'push ARRAY "$OPTARG"' --append init:'ARRAY=""'
	#param   :'ARRAY+=("$OPTARG")' --append init:'ARRAY=()' # for bash, etc
	option  OPTION -o --option default:"omission value"
	disp    :'getoptions parser_definition parse "$0"' --generate
	disp    :usage -h --help
	disp    VERSION --version
}

error() {
	case $2 in
		unknown) echo "$@" ;;
		number) echo "option '$1' is not a number" ;;
		range) echo "option '$1' is not a number or out of range ($3 - $4)" ;;
		regex) echo "option '$1' is not match regex ($3)" ;;
		*) return 1 ;; # Display default error
	esac
}

number() {
	case $OPTARG in (*[!0-9]*) return 1; esac
}

range() {
	number && [ "$1" -le "$OPTARG" ] && [ "$OPTARG" -le "$2" ]
}

regex() {
	awk -v s="$OPTARG" -v r="$1" 'BEGIN{exit match(s, r)==0}'
}

multiple() {
	MULTIPLE="${MULTIPLE}${MULTIPLE:+,}${OPTARG}"
}

# Store multiple (escaped) values in one variable in a POSIX compliant way
push() {
	until [ "${2#*\'}" = "$2" ] && eval "$1=\"\$$1 '\${3:-}\$2'\""; do
		set -- "$1" "${2#*\'}" "${2%%\'*}'\"'\"'"
	done
}

eval "$(getoptions parser_definition parse "$0")"
eval "$(getoptions_help parser_definition usage "$0")"
parse "$@"
eval "set -- $REST"

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
echo "REGEX: $REGEX"
echo "MULTIPLE: $MULTIPLE"
echo "OPTION: $OPTION"
disp_array() {
	eval "set -- $1"
	i=0
	while [ $# -gt 0 ] && i=$((i + 1)); do
		echo "ARRAY $i: $1"
		shift
	done
}
disp_array "$ARRAY"
# printf '%s\n' "${ARRAY[@]}" # for bash

i=0
while [ $# -gt 0 ] && i=$((i + 1)); do
	echo "$i: $1"
	shift
done
