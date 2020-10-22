# shellcheck shell=sh
# URL: https://github.com/ko1nksm/getoptions (v1.1.0)
# License: Creative Commons Zero v1.0 Universal
# shellcheck disable=2016
getoptions() {
	_error='' _on=1 _off='' _export='' _plus='' _mode='' _alt='' restargs=''
	_opts='' _no='' _equal=1 _help='' indent='' _indent='	' IFS=' '

	quote() {
		q="$2'" r=''
		while [ "$q" ]; do r="$r${q%%\'*}'\''" && q=${q#*\'}; done
		q="'${r%????}'" && q=${q#\'\'} && q=${q%\'\'}
		eval "$1=\${q:-\"''\"}"
	}

	code() {
		[ "${1#:}" = "$1" ] && c=3 || c=4
		eval "[ ! \${$c:+x} ] || $2 \"\$$c\""
	}

	args() {
		on=$_on off=$_off export=$_export init='@empty' _hasarg=$1
		while [ $# -gt 2 ] && [ "$3" != '--' ] && shift; do
			case $2 in
				--no-* | --\{no-\}*) _no=1 ;;
				-?) [ "${_hasarg#%}" ] || _opts="$_opts${2#-}" ;;
				+*) _plus=1 ;;
				[!-+]*) eval "${2%%:*}=\${2#*:}"
			esac
		done
	}

	defvar() {
		case $init in
			@none) : ;;
			@empty) code "$1" _0 "${export:+export }$1=''" ;;
			@unset) code "$1" _0 "unset $1 ||:" "unset OPTARG ||:; ${1#:}" ;;
			*)
				case $init in @*) eval "init=\"=\${${init#@}}\""; esac
				case $init in [!=]*) _0 "$init"; return 0; esac
				quote init "${init#=}"
				code "$1" _0 "${export:+export }$1=$init" "OPTARG=$init; ${1#:}"
		esac
	}

	setup() {
		restargs=$1 && shift
		for i; do [ "$i" = '--' ] && break; eval "_${i%%:*}=\${i#*:}"; done
		for i in 0 1 2 3 4 5; do
			eval "_$i() { echo \"$indent\$*\"; }"
			indent="${indent}${_indent}"
		done
	}
	flag() { args : "$@"; defvar "$@"; }
	param() { args % "$@"; defvar "$@"; }
	option() { args % "$@"; defvar "$@"; }
	disp() { args : "$@"; }
	msg() { args : _ "$@"; }

	"$@"
	_0 "${restargs:?}=''"

	args() {
		sw='' validate='' pattern='' counter='' default=''
		on=$_on off=$_off export=$_export _both='--{no-}'
		while [ $# -gt 1 ] && [ "$2" != '--' ] && shift; do
			case $1 in
				$_both*) sw="$sw${sw:+ | }--${1#$_both} | --no-${1#$_both}" ;;
				[-+]? | --*) sw="$sw${sw:+ | }$1" ;;
				*) eval "${1%%:*}=\"\${1#*:}\""
			esac
		done
	}

	setup() { :; }
	flag() {
		args "$@"
		code='$OPTARG'
		[ "$counter" ] && on=1 off=-1 code="\$((\${$1:-0}+\${OPTARG:-0}))"
		quote on "$on" && quote off "$off"
		_3 "$sw)"
		_4 '[ "${OPTARG:-}" ] && set -- "$1" noarg && break'
		_4 "eval '[ \${OPTARG+x} ] &&:' && OPTARG=$on || OPTARG=$off"
		valid "$1" "$code"
		_4 ';;'
	}
	param() {
		args "$@"
		_3 "$sw)"
		_4 '[ $# -le 1 ] && set -- "$1" required && break'
		_4 'OPTARG=$2'
		valid "$1" '$OPTARG'
		_4 'shift ;;'
	}
	option() {
		args "$@"
		quote default "$default"
		_3 "$sw)"
		_4 'case $OPTARG in'
		_5 '?*) OPTARG=$2 ;;'
		_5 " *) OPTARG=$default &&" 'set -- "$1" "$@"'
		_4 "esac"
		valid "$1" '$OPTARG'
		_4 'shift ;;'
	}
	valid() {
		set -- "$validate" "$pattern" "$@"
		[ "$1" ] && _4 "$1 || { set -- \"\$1\" ${1%% *}:\$? ${1#* }; break; }"
		[ "$2" ] && {
			quote pattern "$2"
			_4 "case \$OPTARG in $2) ;;"
			_5 "*) set -- \"\$1\" pattern:$pattern; break"
			_4 "esac"
		}
		code "$3" _4 "${export:+export }$3=\"$4\"" "${3#:}"
	}
	disp() {
		args "$@"
		_3 "$sw)"
		code "$1" _4 "echo \"\${$1}\"" "${1#:}"
		_4 'exit 0 ;;'
	}
	msg() { :; }

	_0 "$2() {"
	_1 'OPTIND=$(($#+1))'
	_1 'while OPTARG= && [ $# -gt 0 ]; do'
	[ "$_alt" ] && _2 'case $1 in -[!-]?*) set -- "-$@"; esac'
	_2 'case $1 in'
	wa() { _4 "eval '${1% *}' \${1+'\"\$@\"'}"; }
	[ "$_equal" ] && {
		_3 '--?*=*) OPTARG=$1; shift'
		wa 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}" "$@"'
		_4 ';;'
	}
	[ "$_no" ] && _3 '--no-*) unset OPTARG ;;'
	[ "$_alt" ] || {
		[ "$_opts" ] && {
			_3 "-[$_opts]?*) OPTARG=\$1; shift"
			wa 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}" "$@"'
			_4 ';;'
		}
		_3 '-[!-]?*) OPTARG=$1; shift'
		wa 'set -- "${OPTARG%"${OPTARG#??}"}" "-${OPTARG#??}" "$@"'
		_4 'OPTARG= ;;'
	}
	[ "$_plus" ] && {
		_3 '+??*) OPTARG=$1; shift'
		wa 'set -- "${OPTARG%"${OPTARG#??}"}" "+${OPTARG#??}" "$@"'
		_4 'unset OPTARG ;;'
		_3 '+*) unset OPTARG ;;'
	}
	_2 'esac'
	_2 'case $1 in'
	"$@"
	restargs() {
		_3 "$1"
		_4 'while [ $# -gt 0 ]; do'
		_5 "$restargs=\"\${$restargs}" '\"\${$((${OPTIND:-0}-$#))}\""'
		_5 'shift'
		_4 'done'
		_4 'break ;;'
	}
	restargs '--) shift'
	_3 "[-${_plus:++}]?*)" 'set -- "$1" unknown && break ;;'
	case $_mode in
		+) restargs '*)' ;;
		*) _3 "*) $restargs=\"\${$restargs}" '\"\${$((${OPTIND:-0}-$#))}\""'
	esac
	_2 'esac'
	_2 'shift'
	_1 'done'
	_1 '[ $# -eq 0 ] && { OPTIND=1; unset OPTARG; return 0; }'
	_1 'case $2 in'
	_2 'unknown) set "Unrecognized option: $1" "$@" ;;'
	_2 'noarg) set "Does not allow an argument: $1" "$@" ;;'
	_2 'required) set "Requires an argument: $1" "$@" ;;'
	_2 'pattern:*) set "Does not match the pattern (${2#*:}): $1" "$@" ;;'
	_2 '*) set "Validation error ($2): $1" "$@"'
	_1 'esac'
	[ "$_error" ] && _1 "$_error" '"$@" >&2 || exit $?'
	_1 'echo "$1" >&2'
	_1 'exit 1'
	_0 '}'

	[ ! "$_help" ] || eval "shift 2; getoptions_help $1 $_help" ${3+'"$@"'}
}
