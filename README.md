# getoptions

[![Test](https://github.com/ko1nksm/getoptions/workflows/Test/badge.svg)](https://github.com/ko1nksm/getoptions/actions)
[![codecov](https://codecov.io/gh/ko1nksm/getoptions/branch/master/graph/badge.svg)](https://codecov.io/gh/ko1nksm/getoptions)
[![CodeFactor](https://www.codefactor.io/repository/github/ko1nksm/getoptions/badge)](https://www.codefactor.io/repository/github/ko1nksm/getoptions)
[![GitHub top language](https://img.shields.io/github/languages/top/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/search?l=Shell)
[![License](https://img.shields.io/github/license/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

An elegant option parser for shell scripts (sh, bash and all POSIX shells)

**Feature**: simple, easy-to-use, fast, portable, POSIX compliant, no requirements and practical

## Usage

[basic.sh](./sample/basic.sh)

```sh
#!/bin/sh

. ./getoptions.sh

# shellcheck disable=SC1083,SC2016
parser_definition() {
  setup plus:true -- "Usage: ${2##*/} [options] [arguments...]" '' 'getoptions sample' ''
  mesg -- 'Options:'
  flag    FLAG_A  -a                                        -- "message a"
  flag    FLAG_B  -b                                        -- "message b"
  flag    FLAG_F  -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
  flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
  param   PARAM   -p    --param                             -- "accept --param value / --param=value"
  param   NUMBER  -n    --number    validate:'number "$1"'  -- "accept only numbers"
  option  OPTION  -o    --option    default:"default"       -- "accept -ovalue / --option=value"
  disp    :usage  -h    --help
  disp    VERSION       --version
}

abort() { echo "$@" >&2; exit 1; }
number() {
  case $OPTARG in (*[!0-9]*)
    abort "$1: not a number"
  esac
}

eval "$(getoptions parser_definition parse "$0")"         # Define parse() function
eval "$(getoptions_help parser_definition usage "$0")"    # Define usage() function
parse "$@"
eval "set -- $RESTARGS" # Reset the positional parameters to exclude options
```

```sh
./sample/basic.sh -ab -f +f --flag --no-flag -vvv -p value -ovalue --option=value 1 2 -- 3 -f
```

**Advanced usage**: See [advanced.sh](./sample/advanced.sh)

## Manual

### Miscellaneous notes

- BOOLEAN
  - true: not zero-length string, false: zero-length string.
- FUNCTION
  - Function name only
- CODE
  - Shell script code
- OPTIONS
  - `key:value` arguments - If `:value` is omitted, it is the same as `key:key`.
- `--{no-}foo`
  - Expand to `--foo` and `--no-foo`.

### `getoptions`

Generate a function for option parsing.

`getoptions PARSER_DEFINITION FUNCTION [extra]...`

- `extra` - Passed to the parser definition function

NOTE: You can also only use the generated code without including `getoptions.sh`.

### `getoptions_help`

Generate a function for automatic help generation.

`getoptions PARSER_DEFINITION FUNCTION [extra]...`

- `extra` - Passed to the parser definition function

### `setup`

Setup global settings

`setup [OPTIONS]... [-- [MESSAGE]...]`

- `restargs:STRING` - The variable name for getting rest arguments (default: `RESTARGS`)
- `plus:BOOLEAN` - Those start with `+` are treated as options
- `error:FUNCTION` - A Function for displaying custom error messages
- `on:STRING` - The default true value for the flag (default: `1`)
- `off:STRING` - The default false value for the flag (default: empty string)
- `export:BOOLEAN` - Export variables
- `width:INTEGER` - Width of optional part of help
- `hidden:BOOLEAN` - Do not display in help

### `flag`

Define a option that take no argument

`flag <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [OPTIONS]... [-- [MESSAGE]...]`

- `on:STRING` - The true value for the flag
- `off:STRING` - The false value for the flag
- `counter:BOOLEAN` - Counts the number of flags
- `validate:CODE` - Code for value validation
- `init:[@on | @off | @unset | =STRING | CODE]` - Initial value / Initializer
- `export:BOOLEAN` - Export variables
- `hidden:BOOLEAN` - Do not display in help

### `param`

Define a option that take an argument

`param <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [OPTIONS]... [-- [MESSAGE]...]`

- `validate:CODE` - Code for value validation
- `init:[@unset | =STRING | CODE]` - Initial value / Initializer
- `export:BOOLEAN` - Export variables
- `var` - Variable name displayed in help
- `hidden:BOOLEAN` - Do not display in help

### `option`

Define a option that take an optional argument

`option <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [OPTIONS]... [-- [MESSAGE]...]`

- `default:STRING` - Value when option argument is omitted
- `validate:CODE` - Code for value validation
- `init:[@unset | =STRING | CODE]` - Initial value / Initializer
- `export:BOOLEAN` - Export variables
- `var` - Variable name displayed in help
- `hidden:BOOLEAN` - Do not display in help

### `disp`

Define a option that display only

`disp [OPTIONS]... <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [-- [MESSAGE]...]`

- `hidden:BOOLEAN` - Do not display in help

### `mesg`

Display message in help

`mesg [OPTIONS]... [-- [MESSAGE]...]`

- `hidden:BOOLEAN` - Do not display in help
