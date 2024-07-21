PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

.PHONY: build clean check test testall coverage install uninstall

build: bin/getoptions bin/gengetoptions

clean:
	rm -f bin/getoptions bin/gengetoptions getoptions.tar.gz gengetoptions.tar.gz

check: build
	shellcheck --version
	shellcheck src/* lib/*.sh spec/*.sh examples/*.sh
	bin/gengetoptions library --shellcheck | shellcheck -s sh -
	bin/gengetoptions parser -f examples/parser_definition.sh --shellcheck parser_definition parser prog | shellcheck -

check_with_docker: build
	support/shellcheck.sh --version
	support/shellcheck.sh src/* lib/*.sh spec/*.sh examples/*.sh
	bin/gengetoptions library --shellcheck | support/shellcheck.sh -s sh -
	bin/gengetoptions parser -f examples/parser_definition.sh --shellcheck parser_definition parser prog | support/shellcheck.sh -

test:
	shellspec

test_in_various_shells:
	if type sh; then shellspec -s sh; fi
	if type bash; then shellspec -s bash; fi
	if type busybox; then shellspec -s 'busybox ash'; fi
	if type ksh; then shellspec -s ksh; fi
	if type mksh; then shellspec -s mksh; fi
	# Broken macOS posh gives an error (posh: exit: bad number)
	if type posh && posh -c exit; then shellspec -s posh; fi
	if type yash; then shellspec -s yash; fi
	if type zsh; then shellspec -s zsh; fi

test_with_coverage:
	shellspec -s bash --kcov

dist: build
	tar -C bin -czf getoptions.tar.gz getoptions
	tar -C bin -czf gengetoptions.tar.gz gengetoptions

install: build
	mkdir -p $(BINDIR)
	install -m 755 bin/getoptions $(BINDIR)/getoptions
	install -m 755 bin/gengetoptions $(BINDIR)/gengetoptions

uninstall:
	rm -f $(BINDIR)/getoptions
	rm -f $(BINDIR)/gengetoptions

bin/getoptions: VERSION src/build.sh src/getoptions lib/*.sh
	src/build.sh < src/getoptions > bin/getoptions
	chmod +x bin/getoptions

bin/gengetoptions: VERSION src/build.sh src/gengetoptions
	src/build.sh < src/gengetoptions > bin/gengetoptions
	chmod +x bin/gengetoptions
