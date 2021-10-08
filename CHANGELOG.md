# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) ~~and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0)~~.

This project does not follow SemVer, since modules are independent of each other; thus, SemVer does not make sense. Changes are grouped per module.


## [Unreleased]
### Added
- Add new module: `elasticache`, [#35](https://github.com/dbl-works/terraform/pull/35)
### RDS
- allow ECS to write to specified buckets [#39](https://github.com/dbl-works/terraform/pull/39)

## [v2021.10.08] - 2021-10-08
### Changed
- Ignore minor version changes for RDS, [#37](https://github.com/dbl-works/terraform/pull/37)

## [v2021.10.04] - 2021-10-04
### Changed
- Add documentation for the Outline VPN setup [#31](https://github.com/dbl-works/terraform/pull/31)
- Add Cloudwatch dashboard to ECS module, [#36](https://github.com/dbl-works/terraform/pull/36)

## [v2021.08.24] - 2021-08-24
### Added
- Add new module: `vpn`, [#30](https://github.com/dbl-works/terraform/pull/30)

## [v2021.07.30] - 2021-07-30
### ECS
- adds `allow_internal_traffic_to_ports` to allow configuring arbitrary ports for ECS to LB communication, [#24](https://github.com/dbl-works/terraform/pull/24)
- adds `grant_read_access_to_s3_arns` to allow read access to S3 buckets, [#27](https://github.com/dbl-works/terraform/pull/27)
### CDN
- The CDN now uses CloudFront with SSL certificate, [#26](https://github.com/dbl-works/terraform/pull/26)


## [v2021.07.15.2] - 2021-07-15
### ECS
- allow `ecs:ListTasks` for `ecs-task-execution-policy`, [#23](https://github.com/dbl-works/terraform/pull/23/)


## [v2021.07.15.1] - 2021-07-15
### Added
- Grant access to managed RDS via IAM policy for the created database [#12](https://github.com/dbl-works/terraform/pull/12)


## [v2021.07.15] - 2021-07-15
### Added
- adds CI script to validate and lint all terraform modules, [#18](https://github.com/dbl-works/terraform/pull/18)
### ECS
- Allow describe service & task for `ecs-task-execution-policy` , [#21](https://github.com/dbl-works/terraform/pull/21)


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
