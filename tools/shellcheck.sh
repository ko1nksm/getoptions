#!/bin/sh

set -eu

version=$(cat .shellcheck-version)
cid=$(docker create --rm -i "koalaman/shellcheck:$version" "$@")
docker cp -q ./ "$cid:/mnt"
docker start -ai "$cid"
