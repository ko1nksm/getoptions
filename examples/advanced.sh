#!/bin/bash
# shellcheck disable=SC2153

set -eu

VERSION=0.1
BLOOD_TYPES='A | B | O | AB'
PROG=${0##*/}

: "${LANG:=C}"

# shellcheck disable=SC1083,SC2016,SC2145
parser_definition() {
	# custom helper functions
	array() { param ":append_array $@"; }
	parray() { param ":append_array_posix $@"; } # posix version

	setup   REST error:error on:1 no: export:true plus:true width:35 help:usage abbr:true -- \
		"Usage: $PROG [options...] [arguments...]" '' \
		'getoptions advanced example' ''
	msg     label:"OPTION" -- "DESCRIPTION"
	flag    FLAG_A    -a --flag-a on:1 no: init:= export:
	flag    FLAG_B    -b +b --{no-}flag-b on:ON no:NO init:@no
	flag    FLAG_C    -c +c --{no-}flag-c on:1 no:0 init:@unset
	flag    VERBOSE   -v +v --{no-}verbose counter:true init:=0
	param   PARAM     -p    --param init:="default"
	param   LANG            --lang init:@none # or init:="$LANG" for using current value
	param   NUMBER          --number validate:number
	param   RANGE           --range validate:'range 10 100' \
		-- '10 - 100'
	param   PATTERN         --pattern pattern:'foo | bar' \
		-- 'foo | bar'
	param   BLOOD_TYPE      --blood-type validate:blood_type pattern:"$BLOOD_TYPES" \
		-- "$BLOOD_TYPES"
	param   REGEX           --regex validate:'regex "^[1-9][0-9]*$"' \
		-- '^[1-9][0-9]*$'
	param   :multiple       --multiple init:'MULTIPLE=""' var:MULTIPLE
	array   ARRAY           --array init:'ARRAY=()' var:VALUE
	parray 	PARRAY          --array-posix init:'PARRAY=""' var:VALUE
	param   :'action "$1" p1 p2' --act1 --act2 var:param
	option  OPTION    -o +o --{no-}option on:"on value" no:"no value"
	disp    :"getoptions parser_definition parse ''" --generate \
		-- 'Display parser code'
	disp    :usage -h --help
	disp    VERSION --version
}

error() {
	case $2 in
		unknown) echo "$1" ;;
		number:*) echo "Not a number: $3" ;;
		range:1) echo "Not a number: $3" ;;
		range:2) echo "Out of range ($5 - $6): $3"; return 2 ;;
		pattern:"$BLOOD_TYPES") echo "Invalid blood type: $3"; return 2 ;;
		regex:*) echo "Not match regex ($4): $3" ;;
		*) return 0 ;; # Display default error
	esac
	return 1
}

number() {
	case $OPTARG in (*[!0-9]*) return 1; esac
}

blood_type() {
	# Normalization only
	case $OPTARG in
		a) OPTARG="A" ;;
		b) OPTARG="B" ;;
		[aA][bB]) OPTARG="AB" ;;
		o) OPTARG="O" ;;
	esac
}

range() {
	number || return 1
	[ "$1" -le "$OPTARG" ] && [ "$OPTARG" -le "$2" ] && return 0
	return 2
}

regex() {
	awk -v s="$OPTARG" -v r="$1" 'BEGIN{exit match(s, r)==0}'
}

multiple() {
	MULTIPLE="${MULTIPLE}${MULTIPLE:+,}${OPTARG}"
}

append_array() {
	eval "$1+=(\"\$OPTARG\")"
}

append_array_posix() {
	# Store multiple (escaped) values in one variable in a POSIX compliant way
	set -- "$1" "$OPTARG"
	until [ "${2#*\'}" = "$2" ] && eval "$1=\"\$$1 '\${3:-}\$2'\""; do
		set -- "$1" "${2#*\'}" "${2%%\'*}'\"'\"'"
	done
}

action() {
	# Example of passing options and parameters
	echo "Do action: option => [$1], param=>[$2, $3], arg => [$OPTARG]"
	exit
}

disp_array() {
	echo "$1:"
	shift
	i=0
	while [ $# -gt 0 ] && i=$((i + 1)); do
		echo "  $i: $1"
		shift
	done
}

eval "$(getoptions parser_definition) exit 1"

echo "FLAG_A: $FLAG_A"
echo "FLAG_B: $FLAG_B"
if [ ${FLAG_C+x} ]; then
	echo "FLAG_C: $FLAG_C"
else
	echo "FLAG_C: <unset>"
fi
echo "VERBOSE: $VERBOSE"
echo "PARAM: $PARAM"
echo "LANG: $LANG"
echo "NUMBER: $NUMBER"
echo "RANGE: $RANGE"
echo "PATTERN: $PATTERN"
echo "BLOOD_TYPE: $BLOOD_TYPE"
echo "REGEX: $REGEX"
echo "MULTIPLE: $MULTIPLE"
if [ ${#ARRAY[@]} -eq 0 ]; then
	disp_array ARRAY
else
	disp_array ARRAY "${ARRAY[@]}"
fi
eval disp_array PARRAY "$PARRAY"
echo "OPTION: $OPTION"
echo "VERSION: $VERSION"
disp_array arguments "$@"
