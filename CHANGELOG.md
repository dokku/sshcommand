# Change Log

All notable changes to this project will be documented in this file.

## [0.13.1](https://github.com/dokku/sshcommand/compare/v0.13.0...v0.13.1) - 2021-10-08

### Added

- #64 @josegonzalez Run tests on the release branch

## [0.13.0](https://github.com/dokku/sshcommand/compare/v0.12.0...v0.13.0) - 2021-10-08

### Added

- #59 @josegonzalez Add bullseye to deb release task
- #60 @josegonzalez Chown authorized_keys file as needed

### Removed

- #62 @josegonzalez Drop xenial support

### Changed

- #61 @josegonzalez Switch from CircleCI to Github Actions

## [0.12.0](https://github.com/dokku/sshcommand/compare/v0.11.0...v0.12.0) - 2020-12-19

### Added

- @josegonzalez add support for removing ssh keys by fingerprint
- @josegonzalez add support for help and version flags

## [0.11.0](https://github.com/dokku/sshcommand/compare/v0.10.0...v0.11.0) - 2020-05-06

### Changed

- @josegonzalez Avoid writing acl-add key to temporary file
- @josegonzalez Release packages for focal

## [0.10.0](https://github.com/dokku/sshcommand/compare/v0.9.0...v0.10.0) - 2020-04-03

### Added
- @Filipe-Souza Ability to output JSON format in ssh keys list
- @matthewmueller Add support for Amazon Linux 2

### Changed
- @josegonzalez Drop unsupported debian-based operating systems
- @josegonzalez Do not release to the betafish channel

### Fixed
- @josegonzalez Do not allow users to re-specify an ssh key under a different name
- @josegonzalez Allow user to disable name check when adding a new ssh key
- @josegonzalez Correct shellcheck issues with shellcheck 0.7.0
- @znz Ignore options in key file

## [0.9.0](https://github.com/dokku/sshcommand/compare/v0.8.0...v0.9.0) - 2019-09-20

### Added
- @josegonzalez Add ability to list a single name's keys

## [0.8.0](https://github.com/dokku/sshcommand/compare/v0.7.0...v0.8.0) - 2019-08-10
### Fixed
- @fruitl00p delete_user is now portable

### Added
- @D1ceWard Added arch linux support
- @josegonzalez Move to circleci 2.0
- @josegonzalez Run tests in docker
- @josegonzalez Release packages via CI
- @josegonzalez Add version command

## [0.7.0](https://github.com/dokku/sshcommand/compare/v0.6.0...v0.7.0) - 2017-03-22
### Fixed
- @callahad Only allow one key per file in acl-add. Otherwise, the additional keys get added without the sshcommand wrapper.

### Added
- @michaelshobbs automated releases


## [0.6.0](https://github.com/dokku/sshcommand/compare/v0.5.0...v0.6.0) - 2016-08-26
### Fixed
- @IlyaSemenov Fixed failing unit test for sshcommand list

### Added
- @u2mejc Adds sshcommand list to README.md
- @IlyaSemenov Support unquoted NAME when parsing authorized_keys
- @IlyaSemenov Tests for different authorized_keys format variants
- @IlyaSemenov Compatibility with SHA256 ssh keys

### Changed
- @IlyaSemenov Pinned base Docker image


## [0.5.0](https://github.com/dokku/sshcommand/compare/v0.4.0...v0.5.0) - 2016-06-30
### Added
@u2mejc Add sshcommand-list, add clarity to help


## [0.4.0](https://github.com/dokku/sshcommand/compare/v0.3.0...v0.4.0) - 2016-04-03
### Added
- @josegonzalez Add the ability to specify the key_file as an argument
- @josegonzalez Allow sourcing configuration defaults
- @josegonzalez Allow specifying custom ALLOWED_KEYS via environment variable
- @josegonzalez Allow sourcing of sshcommand as a library
- @josegonzalez Add a test for invalid os-release paths
- @josegonzalez Add support for alpine linux 3.x. Closes #16

### Changed
- @josegonzalez Minor formatting change
- @josegonzalez Make os-release path configurable
- @josegonzalez Avoid polluting the "global" namespace
- @josegonzalez Switch from checking for name to checking for os id
- @josegonzalez Move apt-get call up so we can cache the call


## [0.3.0](https://github.com/dokku/sshcommand/compare/v0.2.0...v0.3.0) - 2016-04-03
### Fixed
- @josegonzalez Exit correctly when command is misused
- @josegonzalez Exit immediately on log-fail call

### Added
- @josegonzalez Add a description to functions
- @josegonzalez Allow user to specify a specific bash
- @josegonzalez Include way to trace command

### Changed
- @josegonzalez Move sshcommand logic into functions
- @josegonzalez Always use [[ instead of [ or test
- @josegonzalez Avoid global variables
- @josegonzalez Always use declare at the top of functions
- @josegonzalez Always use set -eo pipefail
- @josegonzalez Never use backticks, use $( ... )
- @josegonzalez Use log-fail and log-verbose helpers
- @josegonzalez Always use local when setting variables
- @josegonzalez Lowercase the operating system name
- @josegonzalez Use backticks until better testing can get into place
- @josegonzalez Use proper nomenclature for variable
- @josegonzalez Use more precise argument checking
- @josegonzalez Remove errant output redirection
- @josegonzalez Shift args by 1 to simplify argument assignment
- @josegonzalez Remove case in favor of method checking via declare
- @josegonzalez Refactor help output
- @josegonzalez Use same naming schema everywhere


## [0.2.0](https://github.com/dokku/sshcommand/compare/v0.1.0...v0.2.0) - 2016-04-02
### Fixed
- @michaelshobbs fix stale handle stdin. error on no fingerprint

### Added
- @michaelshobbs add tests and make lint pass
- @michaelshobbs [ci skip] add build status to README
- @alessio Add support for SLES, and perhaps more RPM distros
- @michaelshobbs support identifiers with spaces. closes dokku/dokku#1489
- @michaelshobbs match Debian* in f_adduser()
- Oliver Wilkie Add support for Debian-based Raspian OS

### Changed
- @alessio Use the SLES stanza as a generic fallback
- @alessio Use double quote to prevent globbing and word splitting
- @michaelshobbs update build image in README
- @jvanbaarsen Only add SSH key if it doesn't already exists
