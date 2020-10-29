SHELL=bash

test:
	shellspec

check:
	shellcheck getoptions.sh getoptions_help.sh spec/getoptions_spec.sh spec/getoptions_help_spec.sh sample/basic.sh sample/advanced.sh sample/extension.sh

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
