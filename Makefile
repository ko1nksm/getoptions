PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
SHELL=bash

.PHONY: build clean check test testall coverage install uninstall

build: bin/getoptions bin/gengetoptions

clean:
	rm -f bin/getoptions bin/gengetoptions getoptions.tar.gz gengetoptions.tar.gz

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

dist: build
	tar -C bin -czf getoptions.tar.gz getoptions
	tar -C bin -czf gengetoptions.tar.gz gengetoptions

install: build
	install -m 755 bin/getoptions $(BINDIR)/getoptions
	install -m 755 bin/gengetoptions $(BINDIR)/gengetoptions

uninstall:
	rm -f $(BINDIR)/getoptions
	rm -f $(BINDIR)/gengetoptions

bin/getoptions: src/build.sh src/getoptions lib/*.sh
	src/build.sh < src/getoptions > bin/getoptions
	chmod +x bin/getoptions

bin/gengetoptions: src/build.sh src/gengetoptions
	src/build.sh < src/gengetoptions > bin/gengetoptions
	chmod +x bin/gengetoptions
