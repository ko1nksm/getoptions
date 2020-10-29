# getoptions

[![Test](https://github.com/ko1nksm/getoptions/workflows/Test/badge.svg)](https://github.com/ko1nksm/getoptions/actions)
[![codecov](https://codecov.io/gh/ko1nksm/getoptions/branch/master/graph/badge.svg)](https://codecov.io/gh/ko1nksm/getoptions)
[![CodeFactor](https://www.codefactor.io/repository/github/ko1nksm/getoptions/badge)](https://www.codefactor.io/repository/github/ko1nksm/getoptions)
[![GitHub top language](https://img.shields.io/github/languages/top/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/search?l=Shell)
[![License](https://img.shields.io/github/license/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

An elegant option parser and generator for shell scripts (sh, bash and all POSIX shells)

It's simple, easy-to-use, fast, small, flexible, extensible, portable and POSIX compliant. No more loops needed! No more any templates needed!

- [getoptions.sh](./lib/getoptions.sh) - main module
- [getoptions_help.sh](./lib/getoptions_help.sh) - help module (add-on)

## Table of Contents <!-- omit in toc -->

- [Requirements](#requirements)
- [Comparison](#comparison)
  - [with other implementations](#with-other-implementations)
  - [`getopt` vs `getopts` vs `getoptions`](#getopt-vs-getopts-vs-getoptions)
- [Usage](#usage)
  - [Basic](#basic)
  - [Advanced](#advanced)
  - [Extension](#extension)
  - [Use as option parser generator](#use-as-option-parser-generator)
  - [NOTE: 2.x breaking changes](#note-2x-breaking-changes)
- [References](#references)
  - [Global functions](#global-functions)
    - [`getoptions` - Generate a function for option parsing](#getoptions---generate-a-function-for-option-parsing)
      - [About option parser](#about-option-parser)
    - [`getoptions_help` - Generate a function to display help (add-on)](#getoptions_help---generate-a-function-to-display-help-add-on)
      - [Attributes related to the help display](#attributes-related-to-the-help-display)
  - [Helper functions (not globally defined)](#helper-functions-not-globally-defined)
    - [Data types & Initial values](#data-types--initial-values)
    - [`setup` - Setup global settings (mandatory)](#setup---setup-global-settings-mandatory)
    - [`flag` - Define a option that take no argument](#flag---define-a-option-that-take-no-argument)
    - [`param` - Define a option that take an argument](#param---define-a-option-that-take-an-argument)
    - [`option` - Define a option that take an optional argument](#option---define-a-option-that-take-an-optional-argument)
    - [`disp` - Define a option that display only](#disp---define-a-option-that-display-only)
    - [`msg` - Display message in help](#msg---display-message-in-help)
  - [Custom error handler](#custom-error-handler)
  - [Extension (not globally defined)](#extension-not-globally-defined)
    - [`prehook`, `invoke`](#prehook-invoke)
- [For developers](#for-developers)
- [Changelog](#changelog)
- [License](#license)

## Requirements

- No requirements for option parsing (POSIX shell only)
- `cat` is required for optional automatic help generation

## Comparison

### with other implementations

- Supports all POSIX shells (`dash`, `bash 2.0+`, `ksh 88+`, `zsh 3.1+`, etc)
- High portability, fast and small (only ~5KB and ~200 lines)
- It is just a shell function, no external commands and other tools required
- Only one function is defined globally and no global variables are used
  - except the special variables `OPTARG` and `OPTIND`
- Support for [POSIX][POSIX] and [GNU][GNU] compatible option syntax
  - `-a`, `-abc`, `-s`, `+s`, `-s VALUE`, `-sVALUE`, `-vvv`
  - `--flag`, `--no-flag`, `--param VALUE`, `--param=VALUE`, `--option[=VALUE]`
  - Stop option parsing with `--`, Treat `-` as an argument
- Can be invoked action function instead of storing to variable
- Support for validation and custom error messages
- Support for automatic help generation (add-on)
  - additional one function, ~1.2KB and ~50 lines required
- Can be removed a library by using it as a **generator**

[POSIX]: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
[GNU]: https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html

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
| Automatic help generation         | ❌                | ❌                     | ✔️ add-on        |

## Usage

### Basic

[basic.sh](./sample/basic.sh)

```sh
#!/bin/sh
VERSION=0.1

. ./lib/getoptions.sh # or paste it into your script
. ./lib/getoptions_help.sh # if you need automatic help generation

parser_definition() {
  setup   REST plus:true help:usage -- "Usage: ${2##*/} [options...] [arguments...]"
  msg -- '' 'getoptions sample' ''
  msg -- 'Options:'
  flag    FLAG_A  -a                                        -- "message a"
  flag    FLAG_B  -b                                        -- "message b"
  flag    FLAG_F  -f +f --{no-}flag                         -- "expands to --flag and --no-flag"
  flag    VERBOSE -v    --verbose   counter:true init:=0    -- "e.g. -vvv is verbose level 3"
  param   PARAM   -p    --param     pattern:"foo | bar"     -- "accepts --param value / --param=value"
  param   NUMBER  -n    --number    validate:number         -- "accepts only a number value"
  option  OPTION  -o    --option    on:"default"            -- "accepts -ovalue / --option=value"
  disp    :usage  -h    --help
  disp    VERSION       --version
}

number() { case $OPTARG in (*[!0-9]*) return 1; esac; }

# Define the parse function for option parsing
eval "$(getoptions parser_definition parse "$0")"
parse "$@"          # Option parsing
eval "set -- $REST" # Exclude options from arguments

echo "$FLAG_A"
printf '%s\n' "$@"
```

Parses the following options.

```sh
./sample/basic.sh -ab -f +f --flag --no-flag -vvv -p value -ovalue --option=value 1 2 -- 3 -f
```

### Advanced

See [advanced.sh](./sample/advanced.sh)

getoptions was originally developed to improve the maintainability and testability for [ShellSpec][shellspec]
which has number of options. [ShellSpec usage][shellspec_usage] is another good example of how to use getoptions.

[shellspec]: https://shellspec.info/
[shellspec_usage]: https://github.com/shellspec/shellspec/tree/master/lib/libexec/optparser.sh

### Extension

Custom helper function definitions and hooks make it possible to write parser
definitions more simply. For example, if you want to prefix all variables,
you can use hooks.

See [extension.sh](./sample/extension.sh)

### Use as option parser generator

See [generator.sh](./sample/generator.sh)

<details>
<summary>Generated code</summary>

```sh
FLAG=''
VERBOSE='0'
PARAM=''
OPTION=''
REST=''
parse() {
  OPTIND=$(($#+1))
  while OPTARG= && [ $# -gt 0 ]; do
    case $1 in
      --?*=*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}
        ;;
      --no-*) unset OPTARG ;;
      -[po]?*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}"' ${1+'"$@"'}
        ;;
      -[!-]?*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" "-${OPTARG#??}"' ${1+'"$@"'}
        OPTARG= ;;
      +??*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" "+${OPTARG#??}"' ${1+'"$@"'}
        unset OPTARG ;;
      +*) unset OPTARG ;;
    esac
    case $1 in
      -f | +f | --flag | --no-flag)
        [ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set -- noarg "$1" && break
        eval '[ ${OPTARG+x} ] &&:' && OPTARG='1' || OPTARG=''
        FLAG="$OPTARG"
        ;;
      -v | --verbose)
        [ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set -- noarg "$1" && break
        eval '[ ${OPTARG+x} ] &&:' && OPTARG=1 || OPTARG=-1
        VERBOSE="$((${VERBOSE:-0}+${OPTARG:-0}))"
        ;;
      -p | --param)
        [ $# -le 1 ] && set -- required "$1" && break
        OPTARG=$2
        case $OPTARG in foo | bar) ;;
          *) set -- pattern:'foo | bar' "$1"; break
        esac
        PARAM="$OPTARG"
        shift ;;
      -o | --option)
        set -- "$1" "$@"
        [ ${OPTARG+x} ] && {
          case $1 in --no-*) set -- noarg "${1%%\=*}"; break; esac
          [ "${OPTARG:-}" ] && { shift; OPTARG=$2; } || OPTARG='default'
        } || OPTARG=''
        OPTION="$OPTARG"
        shift ;;
      -h | --help)
        usage
        exit 0 ;;
      --version)
        echo "${VERSION}"
        exit 0 ;;
      --) shift
        while [ $# -gt 0 ]; do
          REST="${REST} \"\${$((${OPTIND:-0}-$#))}\""
          shift
        done
        break ;;
      [-+]?*) set -- unknown "$1" && break ;;
      *) REST="${REST} \"\${$((${OPTIND:-0}-$#))}\""
    esac
    shift
  done
  [ $# -eq 0 ] && { OPTIND=1; unset OPTARG; return 0; }
  case $1 in
    unknown) set -- "Unrecognized option: $2" "$@" ;;
    noarg) set -- "Does not allow an argument: $2" "$@" ;;
    required) set -- "Requires an argument: $2" "$@" ;;
    pattern:*) set -- "Does not match the pattern (${1#*:}): $2" "$@" ;;
    *) set -- "Validation error ($1): $2" "$@"
  esac
  echo "$1" >&2
  exit 1
}
usage() {
cat<<'GETOPTIONSHERE'
Usage: generator.sh [options...] [arguments...]

getoptions sample

Options:
  -f, +f, --{no-}flag         expands to --flag and --no-flag
  -v,     --verbose           e.g. -vvv is verbose level 3
  -p,     --param PARAM       accepts --param value / --param=value
  -o,     --option[=OPTION]   accepts -ovalue / --option=value
  -h,     --help
          --version
GETOPTIONSHERE
}
```

</details>

### NOTE: 2.x breaking changes

- Calling `getoptions_help` is no longer needed (see `help` attribute)
- Changed the `default` attribute of the `option` helper function to the `on` attribute
- Improved the custom error handler and changed the arguments
- Disable expansion variables in the help display

## References

### Global functions

#### `getoptions` - Generate a function for option parsing

`getoptions <parser_definition> <parser_name> [arguments]...`

- parser_definition - Option parser definition
- parser_name - Functin name for option parser
- arguments - Passed to the parser definition function

```sh
# Use as generator: Generate a option parser code (`parse` shell function)
getoptions parser_definition parse

# Use as parser: Define `parse` function
eval "$(getoptions parser_definition parse)"
parse "$@" # Option parsing
```

##### About option parser

The optional parser reuses the shell special variables `OPTIND` and `OPTARG`
for a different purpose than `getopts`. When the option parsing is
successfully completed, `OPTIND` is reset to 1 and `OPTARG` is unset.
When option parsing fails, `OPTARG` is set to the value of the failed option.

If you want to use `getoptions` as **option parser generator**, call it without `eval`.
There is no need to include `getoptions.sh` if you use the generated code.

#### `getoptions_help` - Generate a function to display help (add-on)

`getoptions_help <parser_definition> <parser_name> [arguments]...`

- parser_definition - Option parser definition
- parser_name - Functin name for option parser
- arguments - Passed to the parser definition function

```sh
# Use as generator: Generate a help code (`usage` shell function)
getoptions_help parser_definition usage

# Display help: Define `usage` function
eval "$(getoptions_help parser_definition usage)"
usage # Display help
```

This function is called automatically by `getoptions` with the `help` attribute,
but can also be called manually.

##### Attributes related to the help display

```text

+--------------------------- message ---------------------------+
:                                                               :
+--------- label ---------+                                     :
:   width [default: 30]   :                                     :
:                         :                                     :
  -f, +f, --flag           message for --flag
  -l, +l, --long-long-option-name
                           message for --long-long-option-name
  -o, +o, --option VAR     message for --option
|     |            |
|     |            +-- var
|     +-- plus (visible if specified)
+-- leading [default: "  " (two spaces)]
```

NOTE: If you don't like the output, feel free to change it.

### Helper functions (not globally defined)

Helper functions are not defined globally.
They are available only in the `getoptions` and `getoptions_help` functions.

#### Data types & Initial values

| name       | description                                                                       |
| ---------- | --------------------------------------------------------------------------------- |
| SWITCH     | `-?`, `+?`, `--*`, `--{no-}*` (expand to `--flag` and `--no-flag`)                |
| BOOLEAN    | Boolean (true: not zero-length string, false: **zero-length string**)             |
| STRING     | String                                                                            |
| NUMBER     | Number                                                                            |
| STATEMENT  | Function name (arguments can be added) - e.g. `foo`, `foo 1 2 3`                  |
| CODE       | Statement or multiple statements - e.g `foo; bar`                                 |
| KEY-VALUE  | `key:value` style arguments - If `:value` is omitted, it is the same as `key:key` |
| INIT-VALUE | Initial value (`@on`, `@off`, `@unset`, `@none`, `@export`)                       |

| name      | description                                                                  |
| --------- | ---------------------------------------------------------------------------- |
| `@on`     | Set the variable to a positive value. [default: `1`]                         |
| `@off`    | Set the variable to a negative value. [default: empty]                       |
| `@unset`  | Unset the variable                                                           |
| `@none`   | Do not initialization (Use the current value as it is)                       |
| `@export` | Add only export flag without initialization (Use the current value as it is) |

#### `setup` - Setup global settings (mandatory)

`setup <restargs> [settings]... [default attributes]... [-- [messages]...]`

- resrargs (VARIABLE)
  - The variable name for getting rest arguments
  - Specify an empty string when only setting
- settings (KEY-VALUE)
  - `alt`:BOOLEAN - allow long options starting with single `-` (alternative)
    - Unlike `getopt`, the syntax `-abc` and `-sVALUE` cannot be used when enabled.
  - `error`:STATEMENT - Custom error handler
  - `help`:STATEMENT - Define help function (requires `getoptions_help`)
  - `leading`:STRING - Leading characters in the option part of the help [default: "  " (two spaces)]
  - `mode`:STRING - Scanning modes (see `man getopt`) [default: empty]
    - Unlike `getopt`, only `+` supported
  - `plus`:BOOLEAN - Those start with `+` are treated as options [default: auto]
  - `width`:NUMBER - The width of the option part of the help [default: 30]
- default attributes (KEY-VALUE)
  - `export`:BOOLEAN - Export variables [default: empty]
  - `hidden`:BOOLEAN - Do not display in help [default: empty]
  - `init`:[@INIT-VALUE | =STRING | CODE] - Initial value
  - `off`:STRING - The negative value [default: empty]
  - `on`:STRING - The positive value [default: `1`]
- message (STRING)
  - Help messages

#### `flag` - Define a option that take no argument

`flag <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `counter`:BOOLEAN - Counts the number of flags
  - `export`:BOOLEAN - Export variables
  - `hidden`:BOOLEAN - Do not display in help
  - `init`:[@INIT-VALUE | =STRING | CODE] - Initial value
  - `label`:STRING - The option part of the help
  - `off`:STRING - The negative value
  - `on`:STRING - The positive value
  - `pattern`:PATTERN - Pattern to accept
  - `validate`:STATEMENT - Code for value validation
- message (STRING)
  - Help messages

#### `param` - Define a option that take an argument

`param <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `export`:BOOLEAN - Export variables
  - `hidden`:BOOLEAN - Do not display in help
  - `init`:[@INIT-VALUE | =STRING | CODE] - Initial value
  - `label`:STRING - Option part of help message
  - `pattern`:PATTERN - Pattern to accept
  - `validate`:STATEMENT - Code for value validation
  - `var`:STRING - Variable name displayed in help
- message (STRING)
  - Help messages

#### `option` - Define a option that take an optional argument

`option <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `export`:BOOLEAN - Export variables
  - `hidden`:BOOLEAN - Do not display in help
  - `init`:[@INIT-VALUE | =STRING | CODE] - Initial value
  - `label`:STRING - Option part of help message
  - `off`:STRING - The negative value
  - `on`:STRING - The positive value
  - `pattern`:PATTERN - Pattern to accept
  - `validate`:STATEMENT - Code for value validation
  - `var`:STRING - Variable name displayed in help
- message (STRING)
  - Help messages

#### `disp` - Define a option that display only

`disp <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `hidden`:BOOLEAN - Do not display in help
  - `label`:STRING - Option part of help message
- message (STRING)
  - Help messages

#### `msg` - Display message in help

`msg [attributes]... [-- [messages]...]`

- attributes (KEY-VALUE)
  - `hidden`:BOOLEAN - Do not display in help
  - `label`:STRING - Option part of help message
- message (STRING)
  - Help messages

### Custom error handler

Example

```sh
# Validators
number() { case $OPTARG in (*[!0-9]*) return 1; esac; }
range() {
  number || return 1
  [ "$1" -le "$OPTARG" ] && [ "$OPTARG" -le "$2" ] && return 0
  return 2
}

# Custom error handler
#   $1: Default error message
#   $2: Error name
#     - `unknown` (Unrecognized option)
#     - `noarg` (Does not allow an argument)
#     - `required` (Requires an argument)
#     - `pattern:<PATTERN>` (Does not match the pattern)
#     - `validator_name:<STATUS>` (Validation error)
#   $3: Option
#   $4-: Validator name and arguments
#   return: exit status
error() {
  case $2 in
    unknown) echo "Unrecognized option: $3" ;;
    number:*) echo "Not a number: $3" ;;
    range:1) echo "Not a number: $3" ;;
    range:2) echo "Out of range ($4 - $5): $3"; return 2 ;;
    *) return 0 ;; # Display default error
  esac
  return 1
}
```

### Extension (not globally defined)

#### `prehook`, `invoke`

If you define a `prehook` function in the parser definition,
the `prehook` function will be called before helper functions is called.
Use `invoke` to call the original function from within a `prehook` function.

NOTE: The `prehook` function is not called in the help.

```sh
extension() {
  # The prehook is called before helper functions is called.
  prehook() {
    helper=$1 varname_or_action=$2
    shift 2

    # Do something

    invoke "$helper" "$varname_or_action" "$@"
  }
}

parser_definition() {
  extension
  setup   REST
  flag    FLAG -f  --flag
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
  - Unset `OPTARG` when the option parser ends normally. (#3 Cem Keylan)
  - Reset `OPTIND` to 1 when the option parser ends normally.
  - Added `@none` as initial value.
- 2.0.0 - 2020-10-29
  - Improved the custom error handler. [**breaking change**]
    - The default error message is passed as the first argument, and changed the order of the arguments.
    - Adds `:<PATTERN>` to the validator name "pattern" for flexible customization of error message.
    - Adds `:<STATUS>` to the custom validator name for flexible customization of error message.
    - Changed the return value of custom error handler to be used as the exit status.
  - Invoke validator before pattern matching. [**breaking change**]
  - Added extension features (`prehook` and `invoke`).
  - `setup` helper function.
    - Added `help` and `leading` attributes.
      - **Calling `getoptions_help` is no longer needed.** [**breaking change**]
    - Remove `equal` attribute.
  - `option` helper function.
    - Changed the `default` attribute to the `on` attribute. [**breaking change**]
    - Added support `--no-option` syntax and the `off` attribute.
  - `flag`, `param`, `option`, `disp` and `msg` helper function.
    - Added `label` attribute.
  - `setup`, `flag`, `param` and `option` helper function.
    - Added `@export` as initial value.
  - Disable expansion variables in the help display. [**breaking change**]

## License

[Creative Commons Zero v1.0 Universal](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)
