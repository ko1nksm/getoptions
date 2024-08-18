# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.3.2] - 2024-08-17

- Fixes Makefile
- Fixes `-f-` not to be interpreted as `-f --`
- Fixes `-f-flag` not to be interpreted as `-f --flag`

## [3.3.1] - 2024-07-30

### Fixed

- Fixes for Schily Bourne Shell (bosh/pbosh 2023/01/12).
- Fixed broken --shellcheck
- Minor fixes for old yash (POSIXly-correct mode).

### Changed

- gengetoptions: Hide the `-d` (`--definition`) option.

## [3.3.0] - 2021-05-02

### Added

- getoptions: Make the parser name optional
- Support installation via Homebrew

## [3.2.0] - 2021-04-30

### Added

- Added the feature to parse options directly by default parser name

## [3.1.0] - 2021-04-29

### Added

- gengetoptions: Added embed subcommand.

### Changed

- gengetoptions: Deprecate the `-d` (`--definition`) option.

## [3.0.0] - 2021-04-26

### Added

- Added support for `--with-*` and `--without-*` options.
  - #20: Thanks to Cem Keylan.
- Added new option parser generator `gengetoptions`.
- Added build system.
- Added support for handling of missing commands (`eval "$(getoptions ...) exit 1"`).

### Changed

- Changed Attribute `off` to `no`. [**breaking change**]
- Changed initial value `@off` to `@no`. [**breaking change**]
- Renamed `lin/getoptions.sh` to `lin/getoptions_base.sh`. [**breaking change**]
- Moved library generation feature of `getoptions` to `gengetoptions` [**breaking change**]

### Removed

- Removed incomplete scanning modes `=`, `#`. [**breaking change**]
- Removed `getoptions-cli` and replaced it with `gengetoptions`. [**breaking change**]

## [2.5.1] - 2021-01-10

### Changed

- Add SC2034 to shellcheck directive in generated code

### Fixed

- Fixed a bug that omitting the value of key-value would be an incorrect value.
- Fix handling of unknown short options in mode `=` and `#`.

## [2.5.0] - 2020-12-13

### Added

- Added some options for `/bin/getoptions`.
- Added scanning modes `=`, `#`, `@`.

## [2.4.0] - 2020-11-28

### Added

- Added new `/bin/getoptions` (external command version for `getoptions`).

### Changed

- Renamed previous `/bin/getoptions` to `/bin/getoptions-cli`.

## [2.3.0] - 2020-11-17

### Added

- Added getoptions CLI (generator).

### Fixed

- Fixed a bug that omitting the value of key-value would be an incorrect value.

## [2.2.0] - 2020-11-14

### Added

- Support for subcommands.

## [2.1.0] - 2020-11-03

### Added

- Support for abbreviating long options.

## [2.0.1] - 2020-10-30

### Fixed

- Add workaround for ksh88 (fixed only the test).

## [2.0.0] - 2020-10-29

### Added

- `setup` helper function.
  - Added `help` and `leading` attributes.
- `setup`, `flag`, `param` and `option` helper function.
  - Added `@export` as initial value.
- `flag`, `param`, `option`, `disp` and `msg` helper function.
  - Added `label` attribute.
- `option` helper function.
  - Added support `--no-option` syntax and the `off` attribute.
- Added extension features (`prehook` and `invoke`).

### Changed

- Improved the custom error handler. [**breaking change**]
  - The default error message is passed as the first argument, and changed the order of the arguments.
  - Adds `:<PATTERN>` to the validator name "pattern" for flexible customization of error message.
  - Adds `:<STATUS>` to the custom validator name for flexible customization of error message.
  - Changed the return value of custom error handler to be used as the exit status.
- Invoke validator before pattern matching. [**breaking change**]
- `option` helper function.
  - Changed the `default` attribute to the `on` attribute. [**breaking change**]
- Disable expansion variables in the help display. [**breaking change**]
- **Calling `getoptions_help` is no longer needed.** [**breaking change**]

### Removed

- `setup` helper function.
  - Remove `equal` attribute.

## [1.1.0] - 2020-10-21

### Added

- Added `@none` as initial value.

### Changed

- Unset `OPTARG` when the option parser ends normally.
  - #3: Thanks to Cem Keylan.
- Reset `OPTIND` to 1 when the option parser ends normally.

## [1.0.0] - 2020-08-20

### Added

- First release version

[Unreleased]: https://github.com/ko1nksm/getoptions/compare/v3.3.2...HEAD
[3.3.2]: https://github.com/ko1nksm/getoptions/compare/v3.3.1...v3.3.2
[3.3.1]: https://github.com/ko1nksm/getoptions/compare/v3.3.0...v3.3.1
[3.3.0]: https://github.com/ko1nksm/getoptions/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/ko1nksm/getoptions/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/ko1nksm/getoptions/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/ko1nksm/getoptions/compare/v2.5.1...v3.0.0
[2.5.1]: https://github.com/ko1nksm/getoptions/compare/v2.5.0...v2.5.1
[2.5.0]: https://github.com/ko1nksm/getoptions/compare/v2.4.0...v2.5.0
[2.4.0]: https://github.com/ko1nksm/getoptions/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/ko1nksm/getoptions/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/ko1nksm/getoptions/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/ko1nksm/getoptions/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/ko1nksm/getoptions/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/ko1nksm/getoptions/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/ko1nksm/getoptions/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/ko1nksm/getoptions/commits/v1.0.0
