# getoptions

[![Test](https://github.com/ko1nksm/getoptions/workflows/Test/badge.svg)](https://github.com/ko1nksm/getoptions/actions)
[![codecov](https://codecov.io/gh/ko1nksm/getoptions/branch/master/graph/badge.svg)](https://codecov.io/gh/ko1nksm/getoptions)
[![CodeFactor](https://www.codefactor.io/repository/github/ko1nksm/getoptions/badge)](https://www.codefactor.io/repository/github/ko1nksm/getoptions)
[![GitHub top language](https://img.shields.io/github/languages/top/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/search?l=Shell)
[![License](https://img.shields.io/github/license/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

An elegant option parser for shell scripts (sh, bash and all POSIX shells)

**getoptions** is a new option parser (generator) written in POSIX-compliant shell script and released in august 2020.
It is for those who want to support the standard option syntax in shell scripts without bashisms.
Most simple, fast, small, extensible and portable. No more any loops and templates needed!

## Table of Contents <!-- omit in toc -->

- [Comparison](#comparison)
  - [with other implementations](#with-other-implementations)
  - [`getopt` vs `getopts` vs `getoptions`](#getopt-vs-getopts-vs-getoptions)
- [Installation](#installation)
- [Requirements](#requirements)
- [Quickstart](#quickstart)
- [Advanced usage](#advanced-usage)
  - [Subcommand](#subcommand)
  - [Extension](#extension)
  - [getoptions CLI (Use as a option parser generator)](#getoptions-cli-use-as-a-option-parser-generator)
- [References](#references)
  - [Global functions](#global-functions)
    - [`getoptions` - Generate a function for option parsing](#getoptions---generate-a-function-for-option-parsing)
      - [About option parser](#about-option-parser)
      - [About option parser definition function](#about-option-parser-definition-function)
    - [`getoptions_abbr` - Handle abbreviated long options (add-on)](#getoptions_abbr---handle-abbreviated-long-options-add-on)
    - [`getoptions_help` - Generate a function to display help (add-on)](#getoptions_help---generate-a-function-to-display-help-add-on)
      - [Attributes related to the help display](#attributes-related-to-the-help-display)
  - [Helper functions (not globally defined)](#helper-functions-not-globally-defined)
    - [Data types & Initial values](#data-types--initial-values)
    - [`setup` - Setup global settings (mandatory)](#setup---setup-global-settings-mandatory)
    - [`flag` - Define an option that take no argument](#flag---define-an-option-that-take-no-argument)
    - [`param` - Define an option that take an argument](#param---define-an-option-that-take-an-argument)
    - [`option` - Define an option that take an optional argument](#option---define-an-option-that-take-an-optional-argument)
    - [`disp` - Define an option that display only](#disp---define-an-option-that-display-only)
    - [`msg` - Display message in help](#msg---display-message-in-help)
    - [`cmd` - Define a subcommand](#cmd---define-a-subcommand)
  - [Custom error handler](#custom-error-handler)
  - [Extension (not globally defined)](#extension-not-globally-defined)
    - [`prehook`, `invoke`](#prehook-invoke)
  - [NOTE: 2.x breaking changes](#note-2x-breaking-changes)
- [For developers](#for-developers)
- [Changelog](#changelog)
- [License](#license)

## Comparison

### with other implementations

- High portability, supports all environments where works POSIX shells
  - Linux, macOS, BSD, Unix, Windows (WSL, gitbash, cygwin, msys, busybox-w32)
  - `dash`, `bash` 2.0+, `ksh` 88+, `zsh` 3.1+, busybox `ash`, etc
- **Full support for minimal POSIX shells**, no limitations, no bashisms
- The goal is to meet the standard with minimal implementation instead of doing a lot of things
- This is a **pure shell function**, so just include and call it, no other tools required
- Provides flexibility and extensibility by defining options in easy-to-read DSL-like shell script
  - No need for configuration files or definitions with embedded comments
- Support for POSIX [[1]][POSIX] and GNU [[2]][GNU1] [[3]][GNU2] compatible option syntax
  - `-a`, `-abc`, `-s`, `+s`, `-vvv`, `-s VALUE`, `-sVALUE`
  - `--flag`, `--no-flag`, `--param VALUE`, `--param=VALUE`, `--option[=VALUE]`, `--no-option`
  - Stop option parsing with `--` and treat `-` as an argument
  - Support for **subcommands**
- No global variables are used (except the special variables `OPTARG` and `OPTIND`)
- Fast and small, only ~5KB and ~200 lines (base module)
  - Only one shell function is defined globally
  - No external commands required
  - Can be invoked action function and can be extended by shell scripts
  - Support for validation and custom error messages
- Support for **abbreviation option** (add-on)
  - For example, you can specify `--version` by `--ver` (as long as it's not ambiguous)
  - Additional one shell function, ~1.4KB and ~60 lines required
  - No external commands required
- Support for **automatic help generation** (add-on)
  - Additional one shell function, ~1.3KB and ~50 lines required
  - Only the `cat` command is required.
- No worry about license, it's public domain (Creative Commons Zero v1.0 Universal)

Don't want to add `getoptions.sh` to your project?

- Can be used as a **option parser generator**
- Only one function is generated (or one more for automatic help generation)
- Pre-generates the option parser makes more faster

[POSIX]: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
[GNU1]: https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html
[GNU2]: https://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html

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
| Abbreviating long options         | ⚠ GNU only       | ❌                     | ✔️ add-on        |
| Optional argument                 | ⚠ GNU only       | ❌                     | ✔️               |
| Option after arguments            | ⚠ GNU only       | ❌                     | ✔️               |
| Stop option parsing with `--`     | ⚠ GNU only       | ❌                     | ✔️               |
| Scanning modes (see `man getopt`) | ⚠ GNU only       | ❌                     | ✔️ `+` only      |
| Subcommand                        | ❌                | ❌                     | ✔️               |
| Validation by pattern matching    | ❌                | ❌                     | ✔️               |
| Custom validation                 | ❌                | ❌                     | ✔️               |
| Custom error message              | ❌                | ✔️                     | ✔️ more flexible |
| Automatic help generation         | ❌                | ❌                     | ✔️ add-on        |

## Installation

Download from [releases](https://github.com/ko1nksm/getoptions/releases)
and extract it or just do a `git clone`.

```sh
git clone https://github.com/ko1nksm/getoptions.git
```

Copy the necessary files under the [lib](lib) directory to your project or
use the code generated by the `bin/getoptions` command in your project.

## Requirements

- No requirements for option parsing (POSIX shell only)
- `cat` is required for optional automatic help generation

By the way, if you use `getoptions` as an external shell script library,
It is useful to use `readlinkf` to loading from the execution script path
that resolved the symlink.

- [`readlinkf` - POSIX compliant readlink -f implementation for POSIX shell scripts][readlinkf]

[readlinkf]: https://github.com/ko1nksm/readlinkf

## Quickstart

- [getoptions.sh](./lib/getoptions.sh) - Base module
- [getoptions_abbr.sh](./lib/getoptions_abbr.sh) - Abbreviation option module (add-on)
- [getoptions_help.sh](./lib/getoptions_help.sh) - Automatic help generation module (add-on)

```console
$ examples/basic --help

Usage: basic.sh [options...] [arguments...]

getoptions example

Options:
  -a                          message a
  -b                          message b
  -f, +f, --{no-}flag         expands to --flag and --no-flag
  -v,     --verbose           e.g. -vvv is verbose level 3
  -p,     --param PARAM       accepts --param value / --param=value
  -n,     --number NUMBER     accepts only a number value
  -o,     --option[=OPTION]   accepts -ovalue / --option=value
  -h,     --help
          --version
```

See [basic.sh](examples/basic.sh)

```sh
#!/bin/sh
VERSION=0.1

. ./lib/getoptions.sh # or paste it into your script
. ./lib/getoptions_help.sh # if you need automatic help generation
. ./lib/getoptions_abbr.sh # if you need abbreviation option

parser_definition() {
  setup   REST plus:true help:usage abbr:true -- \
    "Usage: ${2##*/} [options...] [arguments...]" ''
  msg -- 'getoptions example' ''
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

It's parses the following options.

```sh
examples/basic.sh -ab -f +f --flag --no-flag -vvv -p value -ovalue --option=value 1 2 -- 3 -f
```

## Advanced usage

```sh
# Try to run it
examples/advanced.sh --help
```

See [advanced.sh](examples/advanced.sh)

getoptions was originally developed to improve the maintainability and testability for [ShellSpec][shellspec]
which has number of options. [ShellSpec optparser][optparser] is another good example of how to use getoptions.

[shellspec]: https://shellspec.info/
[optparser]: https://github.com/shellspec/shellspec/tree/master/lib/libexec/optparser

### Subcommand

```console
$ examples/subcmd.sh --help

Usage: subcmd.sh [global options...] [command] [options...] [arguments...]

subcommand example

Options:
  -g, --global                global flag
  -h, --help
      --version

Commands:
  cmd1      subcommand 1
  cmd2      subcommand 2
  cmd3      subcommand 3


$ examples/subcmd.sh cmd1 --help

Usage: subcmd.sh cmd1 [options...] [arguments...]

subcommand example

Options:
  -a, --flag-a
  -h, --help
```

See [subcmd.sh](examples/subcmd.sh)

```sh
parser_definition() {
  setup   REST help:usage abbr:true -- \
          "Usage: ${2##*/} [global options...] [command] [options...] [arguments...]"
  msg -- '' 'subcommand example' ''
  msg -- 'Options:'
  flag    GLOBAL  -g --global    -- "global flag"
  disp    :usage  -h --help
  disp    VERSION    --version

  msg -- '' 'Commands:'
  cmd cmd1 -- "subcommand 1"
  cmd cmd2 -- "subcommand 2"
  cmd cmd3 -- "subcommand 3"
}

parser_definition_cmd1() {
  setup   REST help:usage abbr:true -- \
          "Usage: ${2##*/} cmd1 [options...] [arguments...]"
  msg -- '' 'subcommand example' ''
  msg -- 'Options:'
  flag    FLAG_A  -a --flag-a
  disp    :usage  -h --help
}
```

### Extension

Since option definitions are shell scripts, they can be extended by defining functions.
Here is a example code to define your own custom helper functions.
It can also be extended by using hooks. For example, you can prefix all variables.

See [extension.sh](examples/extension.sh)

### getoptions CLI (Use as a option parser generator)

When used as a generator, option parser code can be generated in advance.
This eliminates the need to include a library in the script and makes it even faster.

[bin/getoptions](bin/getoptions)

```console
$ bin/getoptions --help

Usage: getoptions [options...] <path> <parser> [arguments...]

Options:
  -d, --definition NAME Specify the parser definition name
                          (default: filename without extensions)
  -i, --indent[=N]      Use N (default: 2) spaces instead of tabs for indentation
      --shellcheck[=DIRECTIVES]
                        Embed the shellcheck directives
                          (default: 'shell=sh disable=SC2004,SC2145,SC2194')
      --no-comments     Do not embed comments
  -h, --help            Display this help and exit
  -v, --version         Display the version and exit
```

```sh
# Try to run it
bin/getoptions --indent=2 --shellcheck examples/parser_definition.sh parser prog
```

<details>
<summary>generated code</summary>

```sh
# shellcheck shell=sh
# Generated by getoptions (BEGIN)
# URL: https://github.com/ko1nksm/getoptions (2.3.0)
FLAG=''
VERBOSE='0'
PARAM=''
OPTION=''
REST=''
# shellcheck disable=SC2004,SC2145,SC2194
parser() {
  OPTIND=$(($#+1))
  while OPTARG= && [ $# -gt 0 ]; do
    set -- "${1%%\=*}" "${1#*\=}" "$@"
    case $1 in -[!-]?*) set -- "-$@"; esac
    while [ ${#1} -gt 2 ]; do
      case $1 in (*[!a-zA-Z0-9_-]*) break; esac
      case '--flag' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --flag"
      esac
      case '--no-flag' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --no-flag"
      esac
      case '--verbose' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --verbose"
      esac
      case '--param' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --param"
      esac
      case '--option' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --option"
      esac
      case '--help' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --help"
      esac
      case '--version' in
        "$1") OPTARG=; break ;;
        $1*) OPTARG="$OPTARG --version"
      esac
      break
    done
    case ${OPTARG# } in
      *\ *)
        eval "set -- $OPTARG $1 $OPTARG"
        OPTIND=$((($#+1)/2)) OPTARG=$1; shift
        while [ $# -gt "$OPTIND" ]; do OPTARG="$OPTARG, $1"; shift; done
        set "Ambiguous option: $1 (could be $OPTARG)" ambiguous "$@"
        error "$@" >&2 || exit $?
        echo "$1" >&2
        exit 1 ;;
      ?*)
        [ "$2" = "$3" ] || OPTARG="$OPTARG=$2"
        shift 3; eval 'set -- "${OPTARG# }"' ${1+'"$@"'}; OPTARG= ;;
      *) shift 2
    esac
    case $1 in -[!-]?*) set -- "-$@"; esac
    case $1 in
      --?*=*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%%\=*}" "${OPTARG#*\=}"' ${1+'"$@"'}
        ;;
      --no-*) unset OPTARG ;;
      +??*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" +"${OPTARG#??}"' ${1+'"$@"'}
        unset OPTARG ;;
      +*) unset OPTARG ;;
    esac
    case $1 in
      '-f'|'+f'|'--flag'|'--no-flag')
        [ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break
        eval '[ ${OPTARG+x} ] &&:' && OPTARG='1' || OPTARG=''
        FLAG="$OPTARG"
        ;;
      '-v'|'--verbose')
        [ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break
        eval '[ ${OPTARG+x} ] &&:' && OPTARG=1 || OPTARG=-1
        VERBOSE="$((${VERBOSE:-0}+$OPTARG))"
        ;;
      '-p'|'--param')
        [ $# -le 1 ] && set "required" "$1" && break
        OPTARG=$2
        case $OPTARG in foo | bar) ;;
          *) set "pattern:foo | bar" "$1"; break
        esac
        PARAM="$OPTARG"
        shift ;;
      '-o'|'--option')
        set -- "$1" "$@"
        [ ${OPTARG+x} ] && {
          case $1 in --no-*) set "noarg" "${1%%\=*}"; break; esac
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
      [-+]?*) set "unknown" "$1"; break ;;
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
  error "$@" >&2 || exit $?
  echo "$1" >&2
  exit 1
}
usage() {
cat<<'GETOPTIONSHERE'
Usage: prog [options...] [arguments...]

getoptions example

Options:
  -f, +f, --{no-}flag         expands to --flag and --no-flag
  -v,     --verbose           e.g. -vvv is verbose level 3
  -p,     --param PARAM       accepts --param value / --param=value
  -o,     --option[=OPTION]   accepts -ovalue / --option=value
  -h,     --help
          --version
GETOPTIONSHERE
}
# Generated by getoptions (END)
```

</details>

See also [generator.sh](examples/generator.sh)

## References

### Global functions

#### `getoptions` - Generate a function for option parsing

This function is, to be exact, an option parser generator.
An option parser is defined by `eval` the generated code.

`getoptions <parser_definition> <parser_name> [arguments]...`

- parser_definition - Option parser definition
- parser_name - Function name for option parser
- arguments - Passed to the parser definition function

```sh
parser_definition() {
  setup REST ...
  ...
}

# Define the parse function for option parsing
eval "$(getoptions parser_definition parse "$0")"
parse "$@"          # Option parsing
eval "set -- $REST" # Exclude options from arguments
```

##### About option parser

The option parser reuses the shell special variables `OPTIND` and `OPTARG`
for a different purpose than `getopts`. When the option parsing is
successfully completed, the `OPTIND` is reset to 1 and the `OPTARG` is unset.
When option parsing fails, the `OPTARG` is set to the value of the failed option.

##### About option parser definition function

The option parser definition functions are called by `getoptions` 2 times
(or 3 times when using automatic help generation).

Since this function is called within a subshell, defining variables and
functions within this function does not pollute the global. Of course,
helper functions are also defined in the subshell.

#### `getoptions_abbr` - Handle abbreviated long options (add-on)

This function is called automatically by `getoptions` with the `abbr` attribute,
Do not call it manually.

#### `getoptions_help` - Generate a function to display help (add-on)

This function is called automatically by `getoptions` with the `help` attribute,
but can also be called manually.

`getoptions_help <parser_definition> <help_name> [arguments]...`

- parser_definition - Option parser definition
- help_name - Function name for help display
- arguments - Passed to the parser definition function

```sh
parser_definition() {
  ...
}

eval "$(getoptions_help parser_definition usage)"
usage
```

##### Attributes related to the help display

```console
$ script.sh ---help

Options:
+----------------------------- message -----------------------------+
:                                                                   :
+----------- label -----------+                                     :
:   width [default: 30]       :                                     :
:                             :                                     :
  -f, +f, --flag              message for --flag
  -l, +l, --long-long-option-name
                              message for --long-long-option-name
  -o, +o, --option VAR        message for --option
|     |            |
|     |            +-- var
|     +-- plus (visible if specified)
+-- leading [default: "  " (two spaces)]

Commands:
+---------------- message ----------------+
:                                         :
+-- label --+                             :
: width [12]:                             :
:           :                             :
  cmd1      subcommand1
  cmd2      subcommand2
  cmd3      subcommand3
|
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
  - Specify `-` if you want to omit the restargs
- settings (KEY-VALUE)
  - `abbr`:BOOLEAN - Handle abbreviated long options (requires `getoptions_abbr`)
  - `alt`:BOOLEAN - allow long options starting with single `-` (alternative)
    - Unlike `getopt`, the syntax `-abc` and `-sVALUE` cannot be used when enabled
  - `error`:STATEMENT - Custom error handler
  - `help`:STATEMENT - Define help function (requires `getoptions_help`)
  - `leading`:STRING - Leading characters in the option part of the help [default: `"  "` (two spaces)]
  - `mode`:STRING - Scanning modes (see `man getopt`) [default: empty]
    - Unlike `getopt`, only `+` supported
  - `plus`:BOOLEAN - Those start with `+` are treated as options [default: auto]
  - `width`:NUMBER - The width of the option or subcommand part of the help [default: `"30,12"`]
- default attributes (KEY-VALUE)
  - `export`:BOOLEAN - Export variables [default: empty]
  - `hidden`:BOOLEAN - Do not display in help [default: empty]
  - `init`:[@INIT-VALUE | =STRING | CODE] - Initial value
  - `off`:STRING - The negative value [default: empty]
  - `on`:STRING - The positive value [default: `1`]
- message (STRING)
  - Help messages

#### `flag` - Define an option that take no argument

`flag <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `abbr`:BOOLEAN - Set empty to disable individually [default: `1` if abbreviation option is enabled]
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

#### `param` - Define an option that take an argument

`param <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `abbr`:BOOLEAN - Set empty to disable individually [default: `1` if abbreviation option is enabled]
  - `export`:BOOLEAN - Export variables
  - `hidden`:BOOLEAN - Do not display in help
  - `init`:[@INIT-VALUE | =STRING | CODE] - Initial value
  - `label`:STRING - Option part of help message
  - `pattern`:PATTERN - Pattern to accept
  - `validate`:STATEMENT - Code for value validation
  - `var`:STRING - Variable name displayed in help
- message (STRING)
  - Help messages

#### `option` - Define an option that take an optional argument

`option <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `abbr`:BOOLEAN - Set empty to disable individually [default: `1` if abbreviation option is enabled]
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

#### `disp` - Define an option that display only

`disp <varname | :action> [switches]... [attributes]... [-- [messages]...]`

- varname (VARIABLE) or action (STATEMENT)
  - Variable name or Action function
- switches (SWITCH)
  - Options
- attributes (KEY-VALUE)
  - `abbr`:BOOLEAN - Set empty to disable individually [default: `1` if abbreviation option is enabled]
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

#### `cmd` - Define a subcommand

`cmd [subcommand]... [-- [messages]...]`

- attributes (KEY-VALUE)
  - `hidden`:BOOLEAN - Do not display in help
  - `label`:STRING - Command part of help message
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
#     - `ambiguous` (Ambiguous option)
#   $3: Option
#   $4-: Validator name and arguments (if $2 is validator_name)
#   $4-: Candidate options (if $2 is ambiguous)
#   return: exit status
error() {
  case $2 in
    unknown) echo "Unrecognized option: $3" ;;
    number:*) echo "Not a number: $3" ;;
    range:1) echo "Not a number: $3" ;;
    range:2) echo "Out of range ($5 - $6): $3"; return 2 ;;
    *) return 0 ;; # Display default error
  esac
  return 1
}
```

The value of the option that caused the error is stored in the `OPTARG` variable.
If the cause of the error is `ambiguous`, the `OPTARG` is stored candidate
options splited by `, `.

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

### NOTE: 2.x breaking changes

- Calling `getoptions_help` is no longer needed (see `help` attribute)
- Changed the `default` attribute of the `option` helper function to the `on` attribute
- Improved the custom error handler and changed the arguments
- Disable expansion variables in the help display

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
- 2.0.1 - 2020-10-30
  - Add workaround for ksh88 (fixed only the test).
- 2.1.0 - 2020-11-03
  - Support for abbreviating long options.
- 2.2.0 - 2020-11-14
  - Support for subcommands.
- 2.3.0 - 2020-11-17
  - Added getoptions CLI (generator).
  - Fixed a bug that omitting the value of key-value would be an incorrect value.

## License

[Creative Commons Zero v1.0 Universal](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

All rights are relinquished and you can used as is or modified in your project.
No credit is also required, but I would appreciate it if you could credit me as the original author.
