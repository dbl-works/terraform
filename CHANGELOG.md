# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) ~~and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0)~~.

This project does not follow SemVer, since modules are independent of each other; thus, SemVer does not make sense. Changes are grouped per module.

## [Unreleased]


## [v2021.07.13] - 2021-07-13
### Added
- Add new module: `nat`, [#13](https://github.com/dbl-works/terraform/pull/13)
### Changed
- fix all readmes, [#16](https://github.com/dbl-works/terraform/pull/16)
- auto-format all code, [#17](https://github.com/dbl-works/terraform/pull/17)
### ECS
- Add optional NLB to ECS module, [#15](https://github.com/dbl-works/terraform/pull/15)


## [v2021.07.09] - 2021-07-09
### Added
- new module: `cdn` [#11](https://github.com/dbl-works/terraform/pull/11)
- new module: `ecr`: [#10](https://github.com/dbl-works/terraform/pull/10)
### Changed
- improvements documentation (all modules)


## [v2021.07.05-2] - 2021-07-05
### Changed
- multiple updates and improvements for various Readme files, [#9](https://github.com/dbl-works/terraform/pull/9), [5e63386](https://github.com/dbl-works/terraform/commit/5e63386c4d1ec42b33993aeb073db9e9db868713), [16053ba](https://github.com/dbl-works/terraform/commit/16053ba8e12e8441dd642001a3e3f8859933beb3), [80ef433](https://github.com/dbl-works/terraform/commit/80ef433ebb7f179a930f84e3f3bdfa6b4476bc7e), [79c64cc](https://github.com/dbl-works/terraform/commit/79c64cc134b017049f0f138bbd2744758e6f2216), [030eea1](https://github.com/dbl-works/terraform/commit/030eea1ca3e092a94931e191dc73bac9783f273f)
### RDS
- allow setting up a standby in a different availability zone for RDS (use that for production), [#8](https://github.com/dbl-works/terraform/pull/8)


## [v2021.07.05] - 2021-07-05
### Added
- new module `secrets`, [#6](https://github.com/dbl-works/terraform/pull/6)
- new module `certificate`, [#7](https://github.com/dbl-works/terraform/pull/7)
### RDS
- document `allow_from_security_groups` for RDS, [13747ea](https://github.com/dbl-works/terraform/commit/13747ea6a04912d0f9ea16ec3700e101b6496e1b)
### ECS
- default health check to to `/healthz`, [#5](https://github.com/dbl-works/terraform/pull/5)

## [v2021.07.01] - 2021-07-01
### Added
- Initial release
