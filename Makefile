SHELL=bash
libs = lib/getoptions.sh lib/getoptions_help.sh lib/getoptions_abbr.sh
specfiles = spec/getoptions_spec.sh spec/getoptions_help_spec.sh
samples = sample/basic.sh sample/advanced.sh sample/extension.sh sample/parser_definition.sh

test:
	shellspec

check:
	shellcheck $(libs) $(specfiles) $(samples)

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
