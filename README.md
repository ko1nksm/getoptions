# getoptions

[![Test](https://github.com/ko1nksm/getoptions/workflows/Test/badge.svg)](https://github.com/ko1nksm/getoptions/actions)
[![codecov](https://codecov.io/gh/ko1nksm/getoptions/branch/master/graph/badge.svg)](https://codecov.io/gh/ko1nksm/getoptions)
[![CodeFactor](https://www.codefactor.io/repository/github/ko1nksm/getoptions/badge)](https://www.codefactor.io/repository/github/ko1nksm/getoptions)
[![GitHub top language](https://img.shields.io/github/languages/top/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/search?l=Shell)
[![License](https://img.shields.io/github/license/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

An elegant option parser for shell scripts (sh, bash and all POSIX shells)

It's simple, easy-to-use, fast, portable, POSIX compliant, practical and no more `for/while` loop!

## Features

- Supports all POSIX shell (`dash`, `bash 2.0+`, `ksh 88+`, `zsh 3.1+`, etc)
- Short option including optional argument (`-a`, `-abc`, `-s`, `-s 123`, `-s123`)
- Long option including optional argument (`--long`, `--long 123`, `--long=123`)
- Counter short option (`-vvv`) and reverse option (`+s`, `--no-long`)
- Parse the options after arguments and treat after `--` as arguments
- Can be invoked function instead of storing to variable
- Validation and custom error messages
- Automatic help generation
- Can be used as a **option parser generator**

## Requirements

- POSIX shell and `cat` command only. (Used only for displaying help)

## Usage

[basic.sh](./sample/basic.sh)

```sh
#!/bin/sh
VERSION=0.1

. ./getoptions.sh # or paste it into your script
. ./getoptions_help.sh # if you need automatic help generation

parser_definition() {
  setup   REST plus:true -- "Usage: ${2##*/} [options...] [arguments...]"
  msg -- '' 'getoptions sample' ''
  msg -- 'Options:'
  flag    FLAG_A  -a                                        -- "message a"
  flag    FLAG_B  -b                                        -- "message b"
  flag    FLAG_F  -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
  flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
  param   PARAM   -p    --param                             -- "accepts --param value / --param=value"
  param   NUMBER  -n    --number    validate:number         -- "accepts only a number value"
  option  OPTION  -o    --option    default:"default"       -- "accepts -ovalue / --option=value"
  disp    :usage  -h    --help
  disp    VERSION       --version
}

number() { case $OPTARG in (*[!0-9]*) return 1; esac; }

# Define the parse function for option parsing
eval "$(getoptions parser_definition parse "$0")"
# Define the usage function for displaying help (optional)
eval "$(getoptions_help parser_definition usage "$0")"

parse "$@"          # Option parsing
eval "set -- $REST" # Exclude options from arguments

echo "$FLAG_A"
printf '%s\n' "$@"
```

Parses the following options.

```sh
./sample/basic.sh -ab -f +f --flag --no-flag -vvv -p value -ovalue --option=value 1 2 -- 3 -f
```

**Advanced usage**: See [advanced.sh](./sample/advanced.sh)

## `getopt` vs `getopts` vs `getoptions`

|                                   | getopt           | getopts               | getoptions     |
| --------------------------------- | ---------------- | --------------------- | -------------- |
| Implementation                    | External command | Shell builtin command | Shell function |
| Portability                       | No               | Yes                   | Yes            |
| Short option beginning with `-`   | ✔️                | ✔️                     | ✔️              |
| Short option beginning with `+`   | ❌                | ⚠ zsh, ksh, mksh only | ✔️              |
| Long option beginning with `--`   | ⚠ GNU only       | ❌                     | ✔️              |
| Long option beginning with `-`    | ⚠ GNU only       | ❌                     | ✔️ limited      |
| Abbreviating long options         | ⚠ GNU only       | ❌                     | ❌              |
| Optional argument                 | ⚠ GNU only       | ❌                     | ✔️              |
| Option after arguments            | ⚠ GNU only       | ❌                     | ✔️              |
| Double dash (`--`)                | ⚠ GNU only       | ❌                     | ✔️              |
| Scanning modes (see `man getopt`) | ⚠ GNU only       | ❌                     | ✔️ `+` only     |
| Validation                        | ❌                | ❌                     | ✔️              |
| Custom error message              | ❌                | ✔️                     | ✔️              |
| Automatic help generation         | ❌                | ❌                     | ✔️              |

## Manual

### Miscellaneous notes

- `--{no-}foo`
  - Expand to `--foo` and `--no-foo`.
- BOOLEAN
  - true: not zero-length string, false: zero-length string.
- CODE
  - Shell script code
- FUNCTION
  - Function name only
- VALIDATOR
  - Function name or Function name with arguments
- OPTIONS
  - `key:value` arguments - If `:value` is omitted, it is the same as `key:key`.

### `getoptions`

Generate a function for option parsing.

`getoptions PARSER_DEFINITION FUNCTION [extra]...`

- `extra` - Passed to the parser definition function

NOTE: If you want to use as **option parser generator**, call it without `eval`.
You can also only use the generated code without including `getoptions.sh`.

### `getoptions_help`

Generate a function to display help.

`getoptions PARSER_DEFINITION FUNCTION [extra]...`

- `extra` - Passed to the parser definition function

### `setup`

Setup global settings (**mandatory**)

`setup <restargs> [OPTIONS]... [-- [MESSAGE]...]`

- `equal:BOOLEAN` - Support `--long=VALUE` style [default: `1`]
- `error:FUNCTION` - A Function for displaying custom error messages
- `export:BOOLEAN` - Export variables [default: empty]
- `hidden:BOOLEAN` - Do not display in help [default: empty]
- `mode:MODE` - Scanning modes (only `+` supported) [default: empty]
- `off:STRING` - The default false value for the flag [default: empty]
- `on:STRING` - The default true value for the flag [default: `1`]
- `plus:BOOLEAN` - Those start with `+` are treated as options [default: auto]
- `restargs:STRING` - The variable name for getting rest arguments
- `width:INTEGER` - Width of optional part of help [default: 30]

### `flag`

Define a option that take no argument

`flag <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [OPTIONS]... [-- [MESSAGE]...]`

- `alt:BOOLEAN` - allow long options starting with single
  - Unlike `getopt`, the syntaxes `-abc` and `-s123` cannot be used when enabled.
- `counter:BOOLEAN` - Counts the number of flags
- `export:BOOLEAN` - Export variables
- `hidden:BOOLEAN` - Do not display in help
- `init:[@on | @off | @unset | =STRING | CODE]` - Initial value / Initializer
- `off:STRING` - The false value for the flag
- `on:STRING` - The true value for the flag
- `validate:VALIDATOR` - Code for value validation

### `param`

Define a option that take an argument

`param <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [OPTIONS]... [-- [MESSAGE]...]`

- `export:BOOLEAN` - Export variables
- `hidden:BOOLEAN` - Do not display in help
- `init:[@unset | =STRING | CODE]` - Initial value / Initializer
- `validate:VALIDATOR` - Code for value validation
- `var` - Variable name displayed in help

### `option`

Define a option that take an optional argument

`option <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [OPTIONS]... [-- [MESSAGE]...]`

- `default:STRING` - Value when option argument is omitted
- `export:BOOLEAN` - Export variables
- `hidden:BOOLEAN` - Do not display in help
- `init:[@unset | =STRING | CODE]` - Initial value / Initializer
- `validate:VALIDATOR` - Code for value validation
- `var` - Variable name displayed in help

### `disp`

Define a option that display only

`disp [OPTIONS]... <VARIABLE | :CODE> [-? | +? | --* | --{no-}*]... [-- [MESSAGE]...]`

- `hidden:BOOLEAN` - Do not display in help

### `msg`

Display message in help

`msg [OPTIONS]... [-- [MESSAGE]...]`

- `hidden:BOOLEAN` - Do not display in help

### Custom error handler

Example

```sh
# $1: Option
# $2: Validation name (unknown, noarg, required or validator name)
# $3-: Validation arguments
error() {
  case $2 in
    unknown) echo "unrecognized option '$1'" ;;
    number) echo "option '$1' is not a number" ;;
    range) echo "option '$1' is not a number or out of range ($3 - $4)" ;;
    *) return 1 ;; # Display default error
  esac
}
```

## Development

Tests are executed using [shellspec](https://github.com/shellspec/shellspec).

```sh
# Install shellspec (if not installed)
curl -fsSL https://git.io/shellspec | sh

# Run tests
shellspec

# Run tests with other shell
shellspec --shell bash
```

## License

[Creative Commons Zero v1.0 Universal](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)
