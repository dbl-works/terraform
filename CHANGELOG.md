# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) ~~and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0)~~.

This project does not follow SemVer, since modules are independent of each other; thus, SemVer does not make sense. Changes are grouped per module.

## [unreleased]

## RDS
- added the option to create a read-replica, [#96](https://github.com/dbl-works/terraform/pull/96)

## VPC-Peering
- added a new module `vpc-peering` to create a VPC Peering Resource, [#96](https://github.com/dbl-works/terraform/pull/96)

## Stack & Cloudflare
- fixed issues when setting up a bastion, [#93](https://github.com/dbl-works/terraform/pull/93)


## [v2022.06.23]

## Cloudflare
- several fixes to the previously released Cloudflare module.A test application was lauchned deployed find screenshots here: [#91](https://github.com/dbl-works/terraform/pull/91)

## Stack
- several fixes to the previously released Stack module. A test application was lauchned deployed find screenshots here: [#91](https://github.com/dbl-works/terraform/pull/91)



## [v2022.06.21]

### Stack
- added new "Stack" module that combines all modules, [#74](https://github.com/dbl-works/terraform/pull/74)

### Cloudflare
- added a new "Cloudflare" module to automate domain validation and routing, [#75](https://github.com/dbl-works/terraform/pull/75)

### IAM
- added a new "IAM" module for various reusable IAM policies e.g. "humans" for AWS console access, "deploy-bot" for a deploy role, "engineer" for application specific ressource access (read and/or write only), [#76](https://github.com/dbl-works/terraform/pull/76)

### Elasticache
- added `snapshot_retention_limit` (defaults to 0) to allow snapshotting, [#77](https://github.com/dbl-works/terraform/pull/77)
- splitted the existing module into two so we can now choose between "cluster mode" or "non-cluster mode". Also fixes usage of `num_cache_nodes` which one previously could not set to any value other than `1` (it now uses a replication group), [#77](https://github.com/dbl-works/terraform/pull/77)



## [v2022.05.02]

### ECS
- allow passing any custom policies to ECS, [#71](https://github.com/dbl-works/terraform/pull/71)



## [v2022.04.14]

### s3-public, s3-private
- replace deprecated syntax [#68](https://github.com/dbl-works/terraform/pull/68), new first-time contributer [samkahchiin](https://github.com/samkahchiin) - thanks! :tada:

### RDS
- Allow listing policies that grant RDS connect [#61](https://github.com/dbl-works/terraform/pull/61)



## [v2022.03.23]

### ecs

- S3 ARNs for read/write will now be auto splatted to include `/*` keys [#65](https://github.com/dbl-works/terraform/pull/65)
- Add PUT permissions on versions for S3 buckets [#66](https://github.com/dbl-works/terraform/pull/66)

### s3-public, s3-private

- Lock AWS provider to v3.x [#67](https://github.com/dbl-works/terraform/pull/67)



## [v2022.03.16]

### ECS

- Allow SQS access in ECS [#62](https://github.com/dbl-works/terraform/pull/62)
- Adds SQS permissions to ecs execution policy [#63](https://github.com/dbl-works/terraform/pull/63)
- Output HTTPS ALB ARN for ECS [#64](https://github.com/dbl-works/terraform/pull/64)



## [v2022.01.12]

### s3-private

- Expose group for usage permissions on private s3 buckets
- Add CORS configuration to allow uploads directly from browsers
- Disable allowing any public object, even if acl attempted manually

### rds

- Allow anyone with `{project}-{environment}-rds-view` role to list all databases



## [v2021.12.17] - 2021-12-17

### RDS

- an initial database is now created with the name `{project}_{environment}` [#52](https://github.com/dbl-works/terraform/pull/52)

### Added

- new module `s3-private`, a basic S3 bucket for private, encrypted files [#51](https://github.com/dbl-works/terraform/pull/51)

### CDN

- removes CloudFront set up, refere to use CloudFront Workers instead. Is now a very simple public S3 container with standardzed settings and tags [#52](https://github.com/dbl-works/terraform/pull/52)



## [v2021.11.13] - 2021-11-13

### ECS

- grant `kms:GenerateDataKey` so we can write to encrypted S3 buckets [#49](https://github.com/dbl-works/terraform/pull/49)
- grant `s3:GetObjectVersion` & `s3:DeleteObjectVersion` so we can read & delete from S3 buckets with versioning [#50](https://github.com/dbl-works/terraform/pull/50), new first-time contributer [UmarTayyab](https://github.com/UmarTayyab) - thanks! :tada:



## [v2021.11.12] - 2021-11-12

### ECS

- `grant_read_access_to_s3_arns` and `grant_write_access_to_s3_arns` can now be omitted [#48](https://github.com/dbl-works/terraform/pull/48)



## [v2021.11.09] - 2021-11-09

### Added

- ECS now returns nlb arn in outputs [#45](https://github.com/dbl-works/terraform/pull/45)



## [v2021.10.25] - 2021-10-25

### Added

- Add new module: `elasticache`, [#35](https://github.com/dbl-works/terraform/pull/35)

### ECS

- Add groups for ECS access [#25](https://github.com/dbl-works/terraform/pull/25)

### CDN

- Added the Cloudfront distribution `id` to the export [#41](https://github.com/dbl-works/terraform/pull/41)

### RDS

- Ignore changes to `latest_restorable_time` for RDS [#40](https://github.com/dbl-works/terraform/pull/40)



## [v2021.10.09] - 2021-10-09

### ECS

- allow ECS to write to specified buckets [#39](https://github.com/dbl-works/terraform/pull/39)



## [v2021.10.08] - 2021-10-08

### RDS

- Ignore minor version changes for RDS, [#37](https://github.com/dbl-works/terraform/pull/37)



## [v2021.10.04] - 2021-10-04

### VPN

- Add documentation for the Outline VPN setup [#31](https://github.com/dbl-works/terraform/pull/31)

### ECS

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
