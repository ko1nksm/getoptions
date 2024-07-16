#!/bin/sh

# Load the generated option parser library into your shell scripts so that
# you can use the `getoptions`, `getoptions_abbr`, and `getoptions_help` 
# shell functions.

set -eu

../bin/gengetoptions library --shellcheck
