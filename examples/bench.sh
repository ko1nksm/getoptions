#!/bin/sh

set -eu

shell="${1:-sh}"
type "$shell" >/dev/null || exit 1
type hyperfine >/dev/null || exit 1

cd "${0%/*}"

# warmup
i=0; while [ "$i" -lt 100000 ]; do i=$((i+1)); done

bench() {
  echo "[Use as $1]"
  export MODE="${1}:${lib}"
  set -- "$shell" ./example.sh \
    --flag1 --flag2 --flag3 \
    --param1 param1 --param2 param2 --param3 param3 \
    --option1=option1 --option2=option2 --option3=option3 \
    a b c d e f g
  hyperfine --warmup 1 "$*"
}


lib=$(mktemp)

# Use as command
bench "command"

# Use as library
gengetoptions library > "$lib"
bench "library"

# Use as generator
export PARSER=parse
gengetoptions parser -f ./example.sh parser_definition "$PARSER" > "$lib"
bench "generator"

rm "$lib"
