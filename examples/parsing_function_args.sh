#!/usr/bin/env bash

# demonstrate use of getoptions for parsing function arguments.
# getoptions was designed for parsing command arguments but works great for functions as well.
# when a function is called, check to see if the parser function exists.
# if it does not exist then create it using getoptions and a parser definition.
# the parser definition is specified internally to the function but it will have global shell scope.
# 

set -euo pipefail

source ./getoptions.sh

function myfunc() {
  # declare all function parameters and the helper variable as local variable
  local my_flag
  local my_param
  local my_option
  # shellcheck disable=SC2034
  local my_version
  local my_param2="world"
  local my_option2

  # declare the helper variable args specified in the parser definition as local
  local args

  # param2 has a prior value that is not specified in the function call
  # shellcheck disable=SC2034
  local param2_current="hello"
  # shellcheck disable=SC2034
  local my_option2_current="quick"

  local parser_name="${FUNCNAME[0]}_parser"
  if [ ! "$(type -t "${parser_name}")" == 'function' ]; then

    myfunc_parser_def() {
      setup   args plus:true help:usage abbr:true -- "Usage: myfunc [options...] [arguments...]" ''
      msg -- 'Options:'
      # shellcheck disable=SC1083
      flag    my_flag    -f +f --{no-}flag
      flag    my_verbose -v    --verbose   counter:true init:=0
      param   my_param   -p    --param     init:="foo" pattern:"foo | bar"
      param   my_param2  -q    --param2    init:="${my_param2}"
      option  my_option  -o    --option    validate:number
      # shellcheck disable=SC1083
      option  my_option2 -n +n --{no-}option2   init:="missing value" on:"on value" no:"no value"
      disp    :usage     -h    --help
      disp    my_version       --version
    }

    number() {
      case $OPTARG in (*[!0-9]*)
        return 1
      esac
    }
    echo "creating parser ${parser_name} from ${parser_name}_def"
    eval "$(getoptions "${parser_name}_def" "${parser_name}")"
  fi

  # call the function arg parser
  "${parser_name}" "${@}"
  # reset the stack $@ variable to the positional arguments
  eval "set -- ${args}"

  # shellcheck disable=SC2034
  readonly my_flag my_param my_option my_version my_param2 my_option2

  #printf "my_flag: %s, my_param: %s, my_option: %s, my_param2: %s, my_option2: %s\n" "${my_flag}" "${my_param}" "${my_option}" "${my_param2}" "${my_option2}"

  echo "  -- arguments begin"
  local arg
  for arg in "${@}"; do
    printf "    %s=%s\n" "${arg}" "${!arg}"
  done
  echo "  -- arguments end"
}


echo "-- parameter with default value foo when parameter is not specified"
myfunc my_param

echo "-- parameter with explicit value bar"
myfunc -p bar my_param

echo "-- long form parameter with explicit value bar"
myfunc --param bar my_param

echo "-- option2 when not specified results in default 'missing value'"
myfunc my_option2

echo "-- option2 explicit on without value results in 'on value'"
myfunc -n my_option2
myfunc --option2 my_option2

echo "-- option2 explicit off without value results in 'no value'"
myfunc +n my_option2
myfunc --no-option2 my_option2

echo "-- option2 with explicit value results in 'myvalue'"
myfunc -nmyvalue my_option2
myfunc --option2=myvalue my_option2

#echo "-- general test"
myfunc -f --flag -p foo --param bar -o1 --option=2 -n -q "some_value" -- my_param my_flag my_param my_param2 my_option my_option2
#myfunc -f --flag -p foo --param bar -o1 --option=9 --option2="some_option" -q "some_param" "A" "B" "C"
#myfunc -f --flag -p foo --param bar -o1 --option=9 -q "some_param" "A" "B" "C"
