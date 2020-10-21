# getoptions

[![Test](https://github.com/ko1nksm/getoptions/workflows/Test/badge.svg)](https://github.com/ko1nksm/getoptions/actions)
[![codecov](https://codecov.io/gh/ko1nksm/getoptions/branch/master/graph/badge.svg)](https://codecov.io/gh/ko1nksm/getoptions)
[![CodeFactor](https://www.codefactor.io/repository/github/ko1nksm/getoptions/badge)](https://www.codefactor.io/repository/github/ko1nksm/getoptions)
[![GitHub top language](https://img.shields.io/github/languages/top/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/search?l=Shell)
[![License](https://img.shields.io/github/license/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

An elegant option parser for shell scripts (sh, bash and all POSIX shells)

It's simple, easy-to-use, fast, portable, POSIX compliant, practical and no more `for/while` loop!

## Table of Contents <!-- omit in toc -->

- [Requirements](#requirements)
- [Comparison](#comparison)
  - [with other implementations](#with-other-implementations)
  - [`getopt` vs `getopts` vs `getoptions`](#getopt-vs-getopts-vs-getoptions)
- [Usage](#usage)
  - [Basic usage](#basic-usage)
  - [Advanced usage](#advanced-usage)
- [References](#references)
  - [Data types and initial values](#data-types-and-initial-values)
  - [Global functions](#global-functions)
    - [`getoptions` - Generate a function for option parsing](#getoptions---generate-a-function-for-option-parsing)
      - [About option parser](#about-option-parser)
    - [`getoptions_help` - Generate a function to display help (optional)](#getoptions_help---generate-a-function-to-display-help-optional)
  - [Helper functions (not globally defined)](#helper-functions-not-globally-defined)
    - [`setup` - Setup global settings (mandatory)](#setup---setup-global-settings-mandatory)
    - [`flag` - Define a option that take no argument](#flag---define-a-option-that-take-no-argument)
    - [`param` - Define a option that take an argument](#param---define-a-option-that-take-an-argument)
    - [`option` - Define a option that take an optional argument](#option---define-a-option-that-take-an-optional-argument)
    - [`disp` - Define a option that display only](#disp---define-a-option-that-display-only)
    - [`msg` - Display message in help](#msg---display-message-in-help)
  - [Custom error handler](#custom-error-handler)
- [For developers](#for-developers)
- [Changelog](#changelog)
- [License](#license)

## Requirements

- No requirements for option parsing (POSIX shell only)
- `cat` is required for optional automatic help generation

## Comparison

### with other implementations

- Supports all POSIX shells (`dash`, `bash 2.0+`, `ksh 88+`, `zsh 3.1+`, etc)
- Implemented as a shell function (~5KB and ~200 lines)
- To use, just include the script file, no installation required
- Fast and portable because no external commands are used
- Only one function is defined globally
- No global variables are used (except special variable `OPTARG` and `OPTIND`)
- Support for POSIX and GNU compatible option syntaxes
  - `-a`, `-abc`, `-s`, `+s`, `-s VALUE`, `-sVALUE`, `-vvv`
  - `--flag`, `--no-flag`, `--param VALUE`, `--param=VALUE`, `--option[=VALUE]`
  - Stop option parsing with `--`, Treat `-` as an argument
- Can be invoked action function instead of storing to variable
- Support for validation and custom error messages
- Support for automatic help generation (optional, additional ~1.2KB and ~50 lines required)
- Can be removed a library by using it as a **generator**

### `getopt` vs `getopts` vs `getoptions`

|                                   | getopt           | getopts               | getoptions      |
| --------------------------------- | ---------------- | --------------------- | --------------- |
| Implementation                    | External command | Shell builtin command | Shell function  |
| Portability                       | No               | Yes                   | Yes             |
| Short option beginning with `-`   | ✔️                | ✔️                     | ✔️               |
| Short option beginning with `+`   | ❌                | ⚠ zsh, ksh, mksh only | ✔️               |
| Combining short options           | ✔️                | ✔️                     | ✔️               |
| Long option beginning with `--`   | ⚠ GNU only       | ❌                     | ✔️               |
| Long option beginning with `-`    | ⚠ GNU only       | ❌                     | ✔️ limited       |
| Abbreviating long options         | ⚠ GNU only       | ❌                     | ❌               |
| Optional argument                 | ⚠ GNU only       | ❌                     | ✔️               |
| Option after arguments            | ⚠ GNU only       | ❌                     | ✔️               |
| Stop option parsing with `--`     | ⚠ GNU only       | ❌                     | ✔️               |
| Scanning modes (see `man getopt`) | ⚠ GNU only       | ❌                     | ✔️ `+` only      |
| Validation by pattern matching    | ❌                | ❌                     | ✔️               |
| Custom validation                 | ❌                | ❌                     | ✔️               |
| Custom error message              | ❌                | ✔️                     | ✔️ more flexible |
| Automatic help generation         | ❌                | ❌                     | ✔️               |

## Usage

### Basic usage

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
  param   PARAM   -p    --param     pattern:"foo | bar"     -- "accepts --param value / --param=value"
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

### Advanced usage

See [advanced.sh](./sample/advanced.sh)

## References

### Data types and initial values

| name      | description                                                                       |
| --------- | --------------------------------------------------------------------------------- |
| SWITCH    | `-?`, `+?`, `--*`, `--{no-}*` (expand to `--flag` and `--no-flag`)                |
| BOOLEAN   | Boolean (true: not zero-length string, false: zero-length string)                 |
| STRING    | String                                                                            |
| NUMBER    | Number                                                                            |
| STATEMENT | Function name (arguments can be added) - e.g. `foo`, `foo 1 2 3`                  |
| CODE      | Shell script code - e.g `foo; bar`                                                |
| KEY-VALUE | `key:value` style arguments - If `:value` is omitted, it is the same as `key:key` |
| `@on`     | Positive value [default: `1`]                                                     |
| `@off`    | Negative value [default: empty]                                                   |
| `@unset`  | Unset variable                                                                    |
| `@none`   | As is (do not initialize)                                                         |

### Global functions

#### `getoptions` - Generate a function for option parsing

`getoptions <parser_definition> <parser_name> [extra]...`

- Parameters
  - `parser_definition` - Option parser definition
  - `parser_name` - Functin name for option parser
  - `extra` - Passed to the parser definition function

##### About option parser

The optional parser reuses the shell special variables `OPTIND` and `OPTARG`
for a different purpose than `getopts`. When the option parsing is
successfully completed, `OPTIND` is reset to 1 and `OPTARG` is unset.
When option parsing fails, `OPTARG` is set to the value of the failed option.

If you want to use as **option parser generator**, call it without `eval`.
You can also only use the generated code without including `getoptions.sh`.

#### `getoptions_help` - Generate a function to display help (optional)

`getoptions_help <parser_definition> <parser_name> [extra]...`

- Parameters
  - `parser_definition` - Option parser definition
  - `parser_name` - Functin name for display help
  - `extra` - Passed to the parser definition function

NOTE: If you don't like the output, feel free to change it.

### Helper functions (not globally defined)

Helper functions are not defined globally.
They are available only in the `getoptions` and `getoptions_help` functions.

#### `setup` - Setup global settings (mandatory)

`setup <restargs> [Options]... [-- [Messages]...]`

- Parameters
  - `restargs` - The variable name for getting rest arguments
- Options (`KEY-VALUE`)
  - `equal:BOOLEAN` - Support `--long=VALUE` style [default: `1`]
  - `error:STATEMENT` - Custom error handler
  - `export:BOOLEAN` - Export variables [default: empty]
  - `hidden:BOOLEAN` - Do not display in help [default: empty]
  - `mode:STRING` - Scanning modes (only `+` supported) [default: empty]
  - `off:STRING` - The default negative value for the flag [default: empty]
  - `on:STRING` - The default positive value for the flag [default: `1`]
  - `plus:BOOLEAN` - Those start with `+` are treated as options [default: auto]
  - `width:NUMBER` - Width of optional part of help [default: 30]
- `[Messages]` - Help messages (only used by `getoptions_help`)

#### `flag` - Define a option that take no argument

`flag <VARIABLE | :STATEMENT> [SWITCH]... [Options]... [-- [Messages]...]`

- Parameters
  - `<VARIABLE | :STATEMENT>` - Variable or Action function
  - `[SWITCH]` - Options
- Options (`KEY-VALUE`)
  - `alt:BOOLEAN` - allow long options starting with single
    - Unlike `getopt`, the syntaxes `-abc` and `-s123` cannot be used when enabled.
  - `counter:BOOLEAN` - Counts the number of flags
  - `export:BOOLEAN` - Export variables
  - `hidden:BOOLEAN` - Do not display in help
  - `init:[@on | @off | @unset | @none | =STRING | CODE]` - Initial value or Initializer
  - `off:STRING` - The negative value
  - `on:STRING` - The positive value
  - `validate:STATEMENT` - Code for value validation
- `[Messages]` - Help messages (only used by `getoptions_help`)

#### `param` - Define a option that take an argument

`param <VARIABLE | :STATEMENT> [SWITCH]... [Options]... [-- [Messages]...]`

- Parameters
  - `<VARIABLE | :STATEMENT>` - Variable or Action function
  - `[SWITCH]` - Options
- Options (`KEY-VALUE`)
  - `export:BOOLEAN` - Export variables
  - `hidden:BOOLEAN` - Do not display in help
  - `init:[@unset | @none | =STRING | CODE]` - Initial value or Initializer
  - `validate:STATEMENT` - Code for value validation
  - `pattern:PATTERN` - Pattern to accept
  - `var` - Variable name displayed in help
- `[Messages]` - Help messages (only used by `getoptions_help`)

#### `option` - Define a option that take an optional argument

`option <VARIABLE | :STATEMENT> [SWITCH]... [Options]... [-- [Messages]...]`

- Parameters
  - `<VARIABLE | :STATEMENT>` - Variable or Action function
  - `[SWITCH]` - Options
- Options (`KEY-VALUE`)
  - `default:STRING` - Value when option argument is omitted
  - `export:BOOLEAN` - Export variables
  - `hidden:BOOLEAN` - Do not display in help
  - `init:[@unset | @none | =STRING | CODE]` - Initial value or Initializer
  - `validate:STATEMENT` - Code for value validation
  - `pattern:PATTERN` - Pattern to accept
  - `var` - Variable name displayed in help
- `[Messages]` - Help messages (only used by `getoptions_help`)

#### `disp` - Define a option that display only

`disp <VARIABLE | :STATEMENT> [SWITCH]... [Options]... [-- [Messages]...]`

- Parameters
  - `<VARIABLE | :STATEMENT>` - Variable or Action function
  - `[SWITCH]` - Options
- Options (`KEY-VALUE`)
  - `hidden:BOOLEAN` - Do not display in help
- `Messages` - Help messages (only used by `getoptions_help`)

#### `msg` - Display message in help

`msg [Options]... [-- [Messages]...]`

- Options (`KEY-VALUE`)
  - `hidden:BOOLEAN` - Do not display in help
- `[Messages]` - Help messages (only used by `getoptions_help`)

### Custom error handler

Example

```sh
# $1: Option
# $2: Validation name (unknown, noarg, required, pattern or validator name)
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

## For developers

Tests are executed using [shellspec](https://github.com/shellspec/shellspec).

```sh
# Install shellspec (if not installed)
curl -fsSL https://git.io/shellspec | sh

# Run tests
shellspec

# Run tests with other shell
shellspec --shell bash
```

## Changelog

- 1.0.0 - 2020-08-20
  - First release version
- 1.1.0 - 2020-10-21
  - Unset `OPTARG` when the option parser ends normally (#3 Cem Keylan)
  - Reset `OPTIND` to 1 when the option parser ends normally
  - Added `@none` as initial value

## License

[Creative Commons Zero v1.0 Universal](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)
