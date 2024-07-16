#!/bin/sh

# Generate an option parser script from the definition file.
# When this script is loaded with the `.` / `source` command, 
# an option parser shell function is defined.

set -eu

../bin/gengetoptions parser -f parser_definition.sh --shellcheck parser_definition parser prog
