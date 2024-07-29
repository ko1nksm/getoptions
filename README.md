# getoptions <!-- omit in toc -->

[![Test](https://github.com/ko1nksm/getoptions/workflows/Test/badge.svg)](https://github.com/ko1nksm/getoptions/actions)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/ko1nksm/getoptions?logo=codefactor)](https://www.codefactor.io/repository/github/ko1nksm/getoptions)
[![Codecov](https://img.shields.io/codecov/c/github/ko1nksm/getoptions?logo=codecov)](https://codecov.io/gh/ko1nksm/getoptions)
[![kcov](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fko1nksm.github.io%2Fgetoptions%2Fcoverage.json&query=percent_covered&label=kcov&suffix=%25)](https://ko1nksm.github.io/getoptions/)
[![GitHub top language](https://img.shields.io/github/languages/top/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/search?l=Shell)
[![License](https://img.shields.io/github/license/ko1nksm/getoptions.svg)](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)<br>
![Linux](https://img.shields.io/badge/Linux-ecd53f?style=flat)
![macOS](https://img.shields.io/badge/macOS-ecd53f?style=flat)
![BSD](https://img.shields.io/badge/BSD-ecd53f?style=flat)
![Solaris](https://img.shields.io/badge/Solaris-ecd53f?style=flat)
![AIX](https://img.shields.io/badge/AIX-ecd53f?style=flat)
![BusyBox](https://img.shields.io/badge/BusyBox-ecd53f?style=flat)
![Windows](https://img.shields.io/badge/Windows-ecd53f?style=flat)
![sh](https://img.shields.io/badge/sh-cec7d1.svg?style=flat)
![bash](https://img.shields.io/badge/bash-cec7d1.svg?style=flat)
![dash](https://img.shields.io/badge/dash-cec7d1.svg?style=flat)
![ksh](https://img.shields.io/badge/ksh-cec7d1.svg?style=flat)
![mksh](https://img.shields.io/badge/mksh-cec7d1.svg?style=flat)
![yash](https://img.shields.io/badge/yash-cec7d1.svg?style=flat)
![zsh](https://img.shields.io/badge/zsh-cec7d1.svg?style=flat)

An elegant option parser for shell scripts (full support for all POSIX shells)

**getoptions** is a new option parser and generator written in POSIX-compliant shell script and released in august 2020.
It is for those who want to support the POSIX / GNU style option syntax in your shell scripts.
Most easy, simple, fast, small, extensible and portable. No more any loops and templates needed!

## TL; DR <!-- omit in toc -->

```sh
#!/bin/sh

VERSION="0.1"

parser_definition() {
  setup   REST help:usage -- "Usage: example.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    FLAG    -f --flag                 -- "takes no arguments"
  param   PARAM   -p --param                -- "takes one argument"
  option  OPTION  -o --option on:"default"  -- "takes one optional argument"
  disp    :usage     --help
  disp    VERSION    --version
}

eval "$(getoptions parser_definition) exit 1"

echo "FLAG: $FLAG, PARAM: $PARAM, OPTION: $OPTION"
printf '%s\n' "$@" # rest arguments
```

It generates a simple [option parser code](#how-to-see-the-option-parser-code) internally and parses the following arguments.

```console
$ example.sh -f --flag -p value --param value -o --option -ovalue --option=value 1 2 3
FLAG: 1, PARAM: value, OPTION: value
1
2
3
```

Automatic help generation is also provided.

```console
$ example.sh --help

Usage: example.sh [options]... [arguments]...

Options:
  -f, --flag                  takes no arguments
  -p, --param PARAM           takes one argument
  -o, --option[=OPTION]       takes one optional argument
      --help
      --version
```

## Table of Contents <!-- omit in toc -->

- [Features](#features)
- [`getopt` vs `getopts` vs `getoptions`](#getopt-vs-getopts-vs-getoptions)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Homebrew / Linuxbrew](#homebrew--linuxbrew)
- [Usage](#usage)
  - [Use as a command](#use-as-a-command)
  - [Use as a library](#use-as-a-library)
  - [Use as a generator](#use-as-a-generator)
  - [Embedding into a file](#embedding-into-a-file)
- [Benchmarks](#benchmarks)
- [How to see the option parser code](#how-to-see-the-option-parser-code)
  - [Arguments containing spaces and quotes](#arguments-containing-spaces-and-quotes)
  - [Why reuse `OPTARG` and `OPTIND` for different purposes?](#why-reuse-optarg-and-optind-for-different-purposes)
  - [About workarounds](#about-workarounds)
- [References](#references)
  - [Global functions](#global-functions)
  - [Helper functions](#helper-functions)
- [Examples](#examples)
  - [Basic](#basic)
  - [Advanced](#advanced)
    - [Custom error handler](#custom-error-handler)
    - [Custom helper functions](#custom-helper-functions)
  - [Subcommand](#subcommand)
  - [Prehook](#prehook)
  - [Extension](#extension)
  - [Practical example](#practical-example)
- [NOTE: 2.x breaking changes](#note-2x-breaking-changes)
- [NOTE: 3.x breaking changes](#note-3x-breaking-changes)
- [For developers](#for-developers)
  - [How to test getoptions](#how-to-test-getoptions)
- [Changelog](#changelog)
- [License](#license)

## Features

- **Full support for all POSIX shells**, no limitations, no bashisms
- High portability, supports all platforms (Linux, macOS, Windows, etc) where works POSIX shells
- Neither `getopt` nor `getopts` is used, and implemented with shell scripts only
- Provides DSL-like shell script way to define parsers for flexibility and extensibility
- No need for code generation from embedded special comments
- Can be used as an **option parser generator** to run without `getoptions`
- Support for POSIX [[1]][POSIX] and GNU [[2]][GNU1] [[3]][GNU2] compliant option syntax
- Support for **long options**
- Support for **subcommands**
- Support for **abbreviation option**
- Support for **automatic help generation**
- Support for options to call action function
- Support for validation and custom error handler
- Works fast with small overhead and small file size (5KB - 8KB) library
- No global variables are used (except the special variables `OPTARG` and `OPTIND`)
- Only a minimum of one (and a maximum of three) global functions are defined as a library
- No worry about license, it's public domain (Creative Commons Zero v1.0 Universal)

[POSIX]: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
[GNU1]: https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html
[GNU2]: https://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html

## `getopt` vs `getopts` vs `getoptions`

|                                 | getopt           | getopts               | getoptions            |
| ------------------------------- | ---------------- | --------------------- | --------------------- |
| Implementation                  | external command | shell builtin command | shell script          |
| Portability                     | No               | Yes                   | Yes                   |
| Short option beginning with `-` | ✔️                | ✔️                     | ✔️                     |
| Short option beginning with `+` | ❌                | ⚠ zsh, ksh, mksh only | ✔️                     |
| Combining short options         | ✔️                | ✔️                     | ✔️                     |
| Long option beginning with `--` | ⚠ GNU only       | ❌                     | ✔️                     |
| Long option beginning with `-`  | ⚠ GNU only       | ❌                     | ✔️ limited             |
| Abbreviating long options       | ⚠ GNU only       | ❌                     | ✔️                     |
| Optional argument               | ⚠ GNU only       | ❌                     | ✔️                     |
| Option after arguments          | ⚠ GNU only       | ❌                     | ✔️                     |
| Stop option parsing with `--`   | ✔️                | ✔️                     | ✔️                     |
| Scanning modes                  | ⚠ GNU only       | ❌                     | ✔️ `+` and enhancement |
| Subcommand                      | ❌                | ❌                     | ✔️                     |
| Validation by pattern matching  | ❌                | ❌                     | ✔️                     |
| Custom validation               | ❌                | ❌                     | ✔️                     |
| Custom error handler            | ❌                | ✔️                     | ✔️ more flexible       |
| Automatic help generation       | ❌                | ❌                     | ✔️                     |

## Requirements

**Almost no requirements.**

- Any POSIX shells
  - `dash` 0.5.4+, `bash` 2.03+, `ksh` 88+, `mksh` R28+, `zsh` 3.1.9+, `yash` 2.29+, busybox `ash` 1.1.3+, etc
- Only `cat` is used for help display, but it can be removed

## Installation

**Download prebuild shell scripts** from [releases](https://github.com/ko1nksm/getoptions/releases).

- getoptions: Option parser
- gengetoptions: Option parser generator

```sh
wget https://github.com/ko1nksm/getoptions/releases/latest/download/getoptions -O $HOME/bin/getoptions
chmod +x $HOME/bin/getoptions

# optional
wget https://github.com/ko1nksm/getoptions/releases/latest/download/gengetoptions -O $HOME/bin/gengetoptions
chmod +x $HOME/bin/gengetoptions
```

Or build and install it yourself.

```sh
git clone https://github.com/ko1nksm/getoptions.git
cd getoptions
make
make install PREFIX=$HOME
```

### Homebrew

```sh
brew tap ko1nksm/getoptions
brew install getoptions
```

## Usage

Support three ways of use. It is better to use it as a command at first,
and then use it as a library or generator as needed.

|      | command | library | generator |
| ---- | ------- | ------- | --------- |
| easy | ★★★     | ★★☆     | ★☆☆       |
| fast | ★☆☆     | ★★☆     | ★★★       |

### Use as a command

Use the `getoptions` command that you installed on your system.
This assumes that you have the `getoptions` command installed,
but it is the easiest to use and is suitable for personal scripts.

The execution speed is slightly slower than using it as a library. (Approx. 15ms overhead)

```sh
parser_definition() {
  setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
  ...
}

eval "$(getoptions parser_definition parse) exit 1"
parse "$@"
eval "set -- $REST"
```

The mysterious `exit 1` above is code for exiting when the `getoptions`
command is not found. The last character output by `getoptions` is `#`.

If you omit the option parser name or use `-`, it will define the default option
parser and parse arguments immediately.

```sh
parser_definition() {
  setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
  ...
}

eval "$(getoptions parser_definition) exit 1"

# The above means the same as the following code.
# eval "$(getoptions parser_definition getoptions_parse) exit 1"
# getoptions_parse "$@"
# eval "set -- $REST"
```

HINT: Are you wondering why the external command can call a shell function?

The external command `getoptions` will output the shell function `getoptions`.
The external command `getoptions` will be hidden by the shell function `getoptions` that defined by `eval`,
and the `getoptions` will be called again, so it can be call the shell function `parser_definition`.

Try running the following command to see what is output.

```console
$ getoptions parser_definition parse
```

### Use as a library

The `getoptions` command is not recommended for use in distribution scripts
because it is not always installed on the system. This problem can be solved by
including getoptions as a shell script library in your shell scripts.

To use getoptions as a library, you need to generate a library using the `gengetoptions` command.
You can optionally adjust the indentation and other settings when generating the library.

```console
$ gengetoptions library > getoptions.sh
```

```sh
. ./getoptions.sh # Or include it here

parser_definition() {
  setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
  ...
}

eval "$(getoptions parser_definition parse)"
parse "$@"
eval "set -- $REST"
```

NOTE for 1.x and 2.x users: The previous version guided you to use `lib/*.sh`.
This is still available, but it is recommended to use `gengetoptions library`.

### Use as a generator

If you do not want to include getoptions in your shell scripts, you can pre-generate an option parser.
It also runs the fastest, so it suitable when you need a lot of options.

```console
$ gengetoptions parser -f examples/parser_definition.sh parser_definition parse prog > parser.sh
```

```sh
. ./parser.sh # Or include it here

parse "$@"
eval "set -- $REST"
```

### Embedding into a file

You can use `gengetoptions embed` to embed the generated code in a file,
which makes maintenance easier.

If you want to write the parser definition in the same file as
the shell script to execute, define it between `@getoptions` and `@end`.
The code contained here will be executed during code generation.

The generated code will be embedded between the `@gengetoptions` and `@end` directives.
The arguments of `@gengetoptions` are the same as the arguments of the `gengetoptions` command,
which allows you to embed the library as well as the parser.

Example

**example.sh**

```sh
#!/bin/sh

set -eu

# @getoptions
parser_definition() {
  setup   REST help:usage -- "Usage: example.sh [options]... [arguments]..." ''
  msg -- 'Options:'
  flag    FLAG    -f --flag                 -- "takes no arguments"
  param   PARAM   -p --param                -- "takes one argument"
  option  OPTION  -o --option on:"default"  -- "takes one optional argument"
  disp    :usage  -h --help
  disp    VERSION    --version
}
# @end

# @gengetoptions parser -i parser_definition parse
#
#     INSERTED HERE
#
# @end

parse "$@"
eval "set -- $REST"

echo "FLAG: $FLAG, PARAM: $PARAM, OPTION: $OPTION"
printf '%s\n' "$@" # rest arguments
```

```console
$ gengetoptions embed --overwrite example.sh
```

## Benchmarks

Ubuntu (dash) Core i7 3.4 Ghz

```ini
[Use as command]
Benchmark 1: sh ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):       4.9 ms ±   0.2 ms    [User: 4.8 ms, System: 0.6 ms]
  Range (min … max):     4.5 ms …   5.8 ms    479 runs

[Use as library]
Benchmark 1: sh ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):       4.1 ms ±   0.2 ms    [User: 3.9 ms, System: 0.4 ms]
  Range (min … max):     3.7 ms …   5.0 ms    661 runs

[Use as generator]
Benchmark 1: sh ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):     827.0 µs ±  77.0 µs    [User: 759.0 µs, System: 100.1 µs]
  Range (min … max):   702.2 µs … 3044.5 µs    2293 runs
```

Ubuntu (bash) Core i7 3.4 Ghz

```ini
[Use as command]
Benchmark 1: bash ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):      18.9 ms ±   0.6 ms    [User: 17.9 ms, System: 1.5 ms]
  Range (min … max):    17.7 ms …  22.0 ms    153 runs

[Use as library]
Benchmark 1: bash ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):      17.7 ms ±   0.6 ms    [User: 16.8 ms, System: 1.4 ms]
  Range (min … max):    16.5 ms …  19.8 ms    160 runs

[Use as generator]
Benchmark 1: bash ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):       2.4 ms ±   0.2 ms    [User: 2.1 ms, System: 0.4 ms]
  Range (min … max):     2.1 ms …   5.3 ms    882 runs
```

macOS (bash), Core i5 2.4 GHz

```ini
[Use as command]
Benchmark 1: sh ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):      68.5 ms ±   5.5 ms    [User: 55.2 ms, System: 12.3 ms]
  Range (min … max):    63.8 ms …  87.8 ms    33 runs

[Use as library]
Benchmark 1: sh ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):      57.1 ms ±   3.6 ms    [User: 49.4 ms, System: 7.3 ms]
  Range (min … max):    54.3 ms …  75.7 ms    47 runs

[Use as generator]
Benchmark 1: sh ./example.sh --flag1 --flag2 --flag3 --param1 param1 --param2 param2 --param3 param3 --option1=option1 --option2=option2 --option3=option3 a b c d e f g
  Time (mean ± σ):       9.6 ms ±   2.3 ms    [User: 4.6 ms, System: 3.9 ms]
  Range (min … max):     7.4 ms …  19.2 ms    125 runs
```

## How to see the option parser code

It is important to know what kind of code is being generated
when the option parser is not working as expected.

If you want to see the option parser code, rewrite it as follows.

```sh
# eval "$(getoptions parser_definition parse) exit 1"

# Preload the getoptions library
# (can be omitted when using getoptions as a library)
eval "$(getoptions -)"

# Output of the option parser
getoptions parser_definition parse
exit
```

The option parsing code generated by getoptions is very simple.

<details>
<summary>Example option parser code</summary>

```sh
FLAG=''
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
      --no-*|--without-*) unset OPTARG ;;
      -[po]?*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" "${OPTARG#??}"' ${1+'"$@"'}
        ;;
      -[fh]?*) OPTARG=$1; shift
        eval 'set -- "${OPTARG%"${OPTARG#??}"}" -"${OPTARG#??}"' ${1+'"$@"'}
        OPTARG= ;;
    esac
    case $1 in
      '-f'|'--flag')
        [ "${OPTARG:-}" ] && OPTARG=${OPTARG#*\=} && set "noarg" "$1" && break
        eval '[ ${OPTARG+x} ] &&:' && OPTARG='1' || OPTARG=''
        FLAG="$OPTARG"
        ;;
      '-p'|'--param')
        [ $# -le 1 ] && set "required" "$1" && break
        OPTARG=$2
        PARAM="$OPTARG"
        shift ;;
      '-o'|'--option')
        set -- "$1" "$@"
        [ ${OPTARG+x} ] && {
          case $1 in --no-*|--without-*) set "noarg" "${1%%\=*}"; break; esac
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
      [-]?*) set "unknown" "$1"; break ;;
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
  echo "$1" >&2
  exit 1
}
usage() {
cat<<'GETOPTIONSHERE'
Usage: example.sh [options]... [arguments]...

Options:
  -f, --flag                  takes no arguments
  -p, --param PARAM           takes one argument
  -o, --option[=OPTION]       takes one optional argument
  -h, --help
      --version
GETOPTIONSHERE
}
# Do not execute
```

</details>

### Arguments containing spaces and quotes

The getoptions correctly handles arguments containing spaces and quotes
without using arrays, which are not available in POSIX shells.

The magic is in the `REST` variable in the following code.

```sh
$ examples.sh --flag 1 --param value 2 -- 3

# examples.sh
...
eval "$(getoptions parser_definition parse "$0") exit 1"
parse "$@"
eval "set -- $REST"

echo "$REST" # => "${2}" "${5}" "${7}"
echo "$@" # => 1 2 3
...
```

### Why reuse `OPTARG` and `OPTIND` for different purposes?

This is to avoid using valuable global variables. The POSIX shell does not have local variables.
Instead of using long variable names to avoid conflicts, we reuse `OPTARG` and `OPTIND`.
This code has been tested to work without any problem with all POSIX shells (e.g. ksh88, bash 2.03).

If you use `getoptions` instead of `getopts` for option parsing, `OPTARG` and `OPTIND` are not needed.
In addition, you can also use `getopts`, since `OPTARG` and `OPTIND` will be correctly reset after use.

If you still don't like it, you can use the `--optarg` and `--optind` options of `gengetoptions` to change the variable name.
In addition, since the license of `getoptions` is CC0, you can modify it to use it as you like.

### About workarounds

The option parser code contains workarounds for some shell bugs.
If you want to know what that code means, please refer to [Workarounds.md](docs/Workarounds.md).

## References

For more information, see [References](docs/References.md).

### Global functions

When the `getoptions` is used as an external command, three global functions,
`getoptions`, `getoptions_help`, and `getoptions_abbr`, are defined in your shell script.

If you are using it as a library, only `getoptions` is required.
The other functions are needed when the corresponding features are used.

### Helper functions

Helper functions are  (`setup`, `flag`, `param`, etc) used to define option parsers,
and are defined only within the global functions described above.

## Examples

### Basic

[basic.sh](examples/basic.sh)

This is an example of basic usage. It should be enough for your personal script.

### Advanced

[advanced.sh](examples/advanced.sh)

Shell scripts distributed as utilities may require advanced features and validation.

#### Custom error handler

By defining the custom error handler, you can change the standard error messages,
respond to additional error messages, and change the exit status.

#### Custom helper functions

By defining your own helper functions, you can easily define advanced options.
For example, getoptions does not have a helper function to assign to the array,
but it can be easily implemented by a custom helper function.

### Subcommand

[subcmd.sh](examples/subcmd.sh)

Complex programs are often implemented using subcommands.
When using subcommands in getoptions, parse the arguments multiple times.
(For example, parse up to the subcommand, and then parse after it.
This design is useful for splitting shell scripts by each subcommand.

### Prehook

[prehook.sh](examples/prehook.sh)

If you define a `prehook` function in the parser definition,
it will be calledbefore helper functions is called.
This allows you to process the arguments before calling the helper function.

This feature was originally designed to handle variable names with prefixes
without complicating getoptions. Therefore, it may not be very flexible.

NOTE: The `prehook` function is not called in the help.

### Extension

TODO: ~~[extension.sh](examples/extension.sh)~~

Recall that the parser definition function is just a shell script.
You can extend the functionality by calling it from your function.
For example, you could add a `required` attribute that means nonsense required options.

### Practical example

getoptions was originally developed to improve the maintainability and testability for [ShellSpec][shellspec]
which has number of options. [ShellSpec optparser][optparser] is another good example of how to use getoptions.

[shellspec]: https://shellspec.info/
[optparser]: https://github.com/shellspec/shellspec/tree/master/lib/libexec/optparser

## NOTE: 2.x breaking changes

- Calling `getoptions_help` is no longer needed (see `help` attribute)
- Changed the `default` attribute of the `option` helper function to the `on` attribute
- Improved the custom error handler and changed the arguments
- Disable expansion variables in the help display

## NOTE: 3.x breaking changes

- Renamed `lib/getoptions.sh` to `lib/getoptions_base.sh`
- Renamed `getoptions-cli` to `gengetoptions`
- Moved library generation feature of `getoptions` to `gengetoptions`
- Removed scanning mode `=` and `#`
- Changed attribute `off` to `no`
- Changed initial value `@off` to `@no`

## For developers

### How to test getoptions

Tests are executed using [shellspec](https://github.com/shellspec/shellspec).

```sh
# Install shellspec (if not installed)
curl -fsSL https://git.io/shellspec | sh

# Run tests
shellspec

# Run tests with other shell
shellspec --shell bash
```

NOTE: Currently, only the option parser is being tested,
and the CLI utilities is not being tested.

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

[Creative Commons Zero v1.0 Universal](https://github.com/ko1nksm/getoptions/blob/master/LICENSE)

All rights are relinquished and you can used as is or modified in your project.
No credit is also required, but I would appreciate it if you could credit me as the original author.
