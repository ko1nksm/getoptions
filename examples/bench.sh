#!/bin/sh

set -eu

type hyperfine || exit 1

cd "${0%/*}"

# warmup
i=0; while [ "$i" -lt 100000 ]; do i=$((i+1)); done

bench() {
  echo "[$1]"
  export MODE="$1"
  set -- ./example.sh --flag --param param --option=option a b c
  hyperfine --warmup 1 "$*"
}

bench "command"

lib="./getoptions-library.sh"
gengetoptions library > "$lib"
bench "library"
rm "$lib"

lib="./getoptions-parser.sh"
gengetoptions parser -f ./example.sh parser_definition - > "$lib"
bench "parser"
rm "$lib"
