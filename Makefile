PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
SHELL=bash

.PHONY: build check test testall coverage install uninstall

build: bin/getoptions bin/getoptions-generate

check:
	shellcheck src/* lib/*.sh spec/*.sh examples/*.sh

test:
	shellspec

testall:
	shellspec -s sh
	shellspec -s bash
	shellspec -s 'busybox ash'
	shellspec -s ksh
	shellspec -s mksh
	shellspec -s posh
	shellspec -s yash
	shellspec -s zsh

coverage:
	shellspec -s bash --kcov --kcov-options "--coveralls-id=$(COVERALLS_REPO_TOKEN)"
	bash <(curl -s https://codecov.io/bash) -s coverage

bin/getoptions: src/build.sh src/getoptions lib/*.sh
	src/build.sh < src/getoptions > bin/getoptions
	chmod +x bin/getoptions

bin/getoptions-generate: src/build.sh src/getoptions-generate
	src/build.sh < src/getoptions-generate > bin/getoptions-generate
	chmod +x bin/getoptions-generate
