# shellcheck shell=sh disable=SC1083

parser_definition() {
	prog=${2:?The program name is not set}
	setup   REST plus:true help:usage abbr:true error alt:true -- \
		"Usage: ${prog##*/} [options...] [arguments...]" ''
	msg -- 'getoptions parser_definition example' ''
	msg -- 'Options:'
	flag    FLAG    -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
	flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
	param   PARAM   -p    --param     pattern:"foo | bar"     -- "accepts --param value / --param=value"
	option  OPTION  -o    --option    on:"default"            -- "accepts -ovalue / --option=value"
	disp    :usage  -h    --help
	disp    VERSION       --version
}
