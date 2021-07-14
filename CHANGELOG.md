# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) ~~and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0)~~.

This project does not follow SemVer, since modules are independent of each other; thus, SemVer does not make sense. Changes are grouped per module.

## [Unreleased]


## [v2021.07.13] - 2021-07-13
### Added
- Add new module: `nat`, #13
### Changed
- fix all readmes, #16
- auto-format all code, #17
### ECS
- Add optional NLB to ECS module, #15


## [v2021.07.09] - 2021-07-09
### Added
- new module: `cdn` #11
- new module: `ecr`: #10
### Changed
- improvements documentation (all modules)


## [v2021.07.05-2] - 2021-07-05
### Changed
- multiple updates and improvements for various Readme files, #9, 5e63386, 16053ba, 80ef433, 79c64cc, 030eea1
### RDS
- allow setting up a standby in a different availability zone for RDS (use that for production), #8


## [v2021.07.05] - 2021-07-05
### Added
- new module `secrets`, #6
- new module `certificate`, #7
### RDS
- document `allow_from_security_groups` for RDS, 13747ea
### ECS
- default health check to to `/healthz`, #5

## [v2021.07.01] - 2021-07-01
### Added
- Initial release
