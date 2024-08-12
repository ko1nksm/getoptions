PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

.PHONY: build
build: bin/getoptions bin/gengetoptions

.PHONY: clean
clean:
	rm -f bin/getoptions bin/gengetoptions getoptions.tar.gz gengetoptions.tar.gz

.PHONY: check
check: build
	shellcheck --version
	shellcheck tools/* src/* lib/*.sh spec/*.sh examples/*.sh
	bin/gengetoptions library --shellcheck | shellcheck -s sh -
	bin/gengetoptions parser -f examples/parser_definition.sh --shellcheck parser_definition parser prog | shellcheck -

.PHONY: check_with_docker
check_with_docker: build
	tools/shellcheck.sh --version
	tools/shellcheck.sh tools/* src/* lib/*.sh spec/*.sh examples/*.sh
	bin/gengetoptions library --shellcheck | tools/shellcheck.sh -s sh -
	bin/gengetoptions parser -f examples/parser_definition.sh --shellcheck parser_definition parser prog | tools/shellcheck.sh -

.PHONY: test
test:
	shellspec

.PHONY: test_in_various_shells
test_in_various_shells:
	if type sh; then shellspec -s sh; fi
	if type dash; then shellspec -s dash; fi
	if type bash; then shellspec -s bash; fi
	if type busybox; then shellspec -s 'busybox ash'; fi
	if type ksh; then shellspec -s ksh; fi
	if type mksh; then shellspec -s mksh; fi
	# Skip broken macOS posh that gives error. (posh: exit: bad number)
	if type posh && posh -c exit; then shellspec -s posh; fi
	if type yash; then shellspec -s yash; fi
	if type zsh; then shellspec -s zsh; fi

.PHONY: test_with_coverage
test_with_coverage:
	shellspec -s bash --kcov

.PHONY: dist
dist: build
	tar -C bin -czf getoptions.tar.gz getoptions
	tar -C bin -czf gengetoptions.tar.gz gengetoptions

.PHONY: install
install: build
	mkdir -p $(BINDIR)
	install -m 755 bin/getoptions $(BINDIR)/getoptions
	install -m 755 bin/gengetoptions $(BINDIR)/gengetoptions

.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/getoptions
	rm -f $(BINDIR)/gengetoptions

bin/getoptions: VERSION tools/build.sh src/getoptions lib/*.sh
	tools/build.sh < src/getoptions > bin/getoptions
	chmod +x bin/getoptions

bin/gengetoptions: VERSION tools/build.sh src/gengetoptions
	tools/build.sh < src/gengetoptions > bin/gengetoptions
	chmod +x bin/gengetoptions
