# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) ~~and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0)~~.

This project does not follow SemVer, since modules are independent of each other; thus, SemVer does not make sense. Changes are grouped per module.

## [Unreleased]
### RDS
- new optional variable for `parameter_group_name`, #213
- parameter group is now created dynamically depending on the engine version (instead of hardcoding version 13 and 14), #213
- allow major version upgrades, #213
- ignore changes to username/password to not trigger a re-creation when the password is rotated, #213

### aws-transfer
- Add AWS transfer family module[#198](https://github.com/dbl-works/terraform/pull/198)

### iam/iam-policy-for-cross-account-access
- Add IAM policy for cross account access [#195](https://github.com/dbl-works/terraform/pull/195)

### iam/iam-for-humans/human-policies
- Allow user to create MFA device under any name [#204](https://github.com/dbl-works/terraform/pull/204)

### ecs-deploy
- :warning: breaking change: this was previously named `ecs_service` which was inconsistent with all other module names and didn't communicate its usage in the name

### slack-chatbot
- deleted this module; it was WIP/broken and a more modular approach is found ins `slack/*` modules

### cloudwatch-kinesis
- Added a new module to send cloudwatch logs to kinesis firehose delivery stream [#206](https://github.com/dbl-works/terraform/pull/206), [#211](https://github.com/dbl-works/terraform/pull/211), [#215](https://github.com/dbl-works/terraform/pull/215)



## [v2023.03.30]

### global-accelerator
- Add `weight` to the load_balancers variables, defaulting to 128 [#194](https://github.com/dbl-works/terraform/pull/194)

### ecs_service
- Add AWS ecs service module [#188](https://github.com/dbl-works/terraform/pull/188), [#192](https://github.com/dbl-works/terraform/pull/192)

### script/database-roles
- Add SQL script for creating DB `readonly` role [#177](https://github.com/dbl-works/terraform/pull/177)

### slack/sentry
- Add Slack notifier for Sentry issue alerts [#184](https://github.com/dbl-works/terraform/pull/184)

### stack/app
- Add Add `elasticache_name` as variables [#187](https://github.com/dbl-works/terraform/pull/187)
- Add `kms_app_arns` as variables
- Fix path for buckets to allow access to files at root level [#180](https://github.com/dbl-works/terraform/pull/180)

### S3
- Allow creating a S3 Bucket with a multi region KMS Key [#190](https://github.com/dbl-works/terraform/pull/190)

### Cloudflare
- Added DNSSEC config [#181](https://github.com/dbl-works/terraform/pull/181)

### VPC Peering
- Create routes for public subnet [#179](https://github.com/dbl-works/terraform/pull/179)



## [v2023.03.06]

### iam/iam-policy-for-secrets
- Added a new module to manage access to the secretsmaanger and kms based on project_access variables. [#175](https://github.com/dbl-works/terraform/pull/175)

### lambda
- Added a new module to manage Lambdas that can (optionally) access resources within a VPC and outside a VPC (e.g. secrets)
[#173](https://github.com/dbl-works/terraform/pull/173)

### RDS
- consistenly use `local.name` instead of `project-environment`. By default, both are the same, but `local.name` can be overridden to allow for more flexibility; e.g. when one needs to launch multiple RDS instances for the same project/environment. [#154](https://github.com/dbl-works/terraform/pull/154)
- always trim engine_version to its major version only. This allow AWS to do the minor/patch version updates automatically. [#155](https://github.com/dbl-works/terraform/pull/155)

### Stack/app
- Make S3 replicas as optional variables. [#158](https://github.com/dbl-works/terraform/pull/158)
- Make NAT optional. NAT is not created if `public_ips` is not given. [#164](https://github.com/dbl-works/terraform/pull/164)
- Add certificate_arn as optional variables. Allows the user to decide which aws acm certificate to be used.[#170](https://github.com/dbl-works/terraform/pull/170)
- Always use the most recent aws_acm_certificate to avoid the multiple certificates error.[#170](https://github.com/dbl-works/terraform/pull/170)
- Introduce new variables skip_elasticache to skip the creation of elasticache in stack/app module. [#174](https://github.com/dbl-works/terraform/pull/174)

### Stack/setup
- Remove the creation of aws_acm_certificate when is_read_replica_on_same_domain is true. [#170](https://github.com/dbl-works/terraform/pull/170)
- Add cloudflare_validation_hostnames as output.[#170](https://github.com/dbl-works/terraform/pull/170)
- Add aws_acm_certificate_arn in the output. [#174](https://github.com/dbl-works/terraform/pull/174)

### iam/iam-policy-for-taggable-resources
- Add BatchGet* and BatchCheck* commands to include the missing read permissions for ECR (e.g. BatchCheckLayerAvailability, BatchGetImage). [#162](https://github.com/dbl-works/terraform/pull/162)
- Separate the ECSAccess into 2 policies and shorten the policy json documents. [#175](https://github.com/dbl-works/terraform/pull/175)
- Remove the iam policy for secrets because tag policy doesn't work well with secretsmanager and kms. [#175](https://github.com/dbl-works/terraform/pull/175)

### ecr
- Add lifecycle policy rules. [#169](https://github.com/dbl-works/terraform/pull/169)
- Add default lifecycle policy rules to keep at least 1 images on important branchs. [#172](https://github.com/dbl-works/terraform/pull/172)



## [v2022.12.12]

## Autoscaling/ECS
- added new module to configure auto-scaling for ECS [#136](https://github.com/dbl-works/terraform/pull/136), [#140](https://github.com/dbl-works/terraform/pull/140), [#142](https://github.com/dbl-works/terraform/pull/142), [#143](https://github.com/dbl-works/terraform/pull/143)

## ECS
- allow creating a cluster without passing secret/KMS key ARN(s) [#146](https://github.com/dbl-works/terraform/pull/146)
- Enable that we can (dis)allow listing all ECS Clusters or S3 Buckets [#149](https://github.com/dbl-works/terraform/pull/149)
- Adds missing permissions to retrieve object versions from S3 [#150](https://github.com/dbl-works/terraform/pull/150)

## Multiple Modules
- Internal refactoring, better outputs, etc [#139](https://github.com/dbl-works/terraform/pull/139), [#148](https://github.com/dbl-works/terraform/pull/148)

## IAM
- adds IAM role/group to grant access to view X-Ray [#138](https://github.com/dbl-works/terraform/pull/138)

## Snowflake
- Fixed Inconsistent Return Type for Cloudwatch/Snowflake Output [#132](https://github.com/dbl-works/terraform/pull/132)
- Adds SQL Script For A Readonly User/Role [#135](https://github.com/dbl-works/terraform/pull/135)
- fivetran/connectors/lambda: Improve and extract lambda module [#137](https://github.com/dbl-works/terraform/pull/137), [#145](https://github.com/dbl-works/terraform/pull/145)

## RDS
- Add DB instructions to connect DB to Fivetran, [#125](https://github.com/dbl-works/terraform/pull/125)

## [v2022.09.30]

## Elasticache
- set `cluster_mode`, `maxmemory_policy`, `elasticache_node_count`, `elasticache_automatic_failover_enabled` as variables instead of hardcore values.

## Analytics, Cloudwatch-Snowflake, Fivetran, Snowflake/Cloud
- added new modules to launch a **Snowflake Warehouse**, and connect various data sources to the warehouse using **Fivetran**. The "Analytics" module brings all these sub modules together and introduces default values. Submodules can also be combined in any way if more flexibility is needed. These modules have been tested and are operational, though there are still some rough edges (see for example [Issue #127](https://github.com/dbl-works/terraform/issues/127)).

## RDS
- set replacement of non-alphanumeric chars with underscore on RDS DBName value to avoid naming validation errors.



## [v2022.09.07]

## Elasticache
- added `maxmemory_policy` as the optional options. Default value is `volatile-lru`

## Slack
- added a new module to launch Chatbot and SNS topic required for Slack message, [#116](https://github.com/dbl-works/terraform/pull/116)

## Cloudwatch
- added a new module to launch cloudwatch module [#116](https://github.com/dbl-works/terraform/pull/116)

## RDS
- add option to enable DB replication with new parameter `enable_replication` [#119](https://github.com/dbl-works/terraform/pull/119)
- if `enable_replication` is changed on a running DB, the DB will need to be restarted manually



## [v2022.08.05]

## Elasticache
- `multi_az_enabled` can now optionally be turned off

## Secrets
- Improved documentation
- allow `description` to be optional

## Stack
- pass `multi_az_enabled` through to Elasticache
- fix `allow_from_security_groups` to have a predictable length for terraform



## [v2022.08.03]

## Global Accelerator
- added a new module to launch an AWS Global Accelerator, [#104](https://github.com/dbl-works/terraform/pull/104)

## ElastiCache
- added `data_tiering_enabled` to the available options, defaulting to `false`, [#100](https://github.com/dbl-works/terraform/pull/100)
- added `name` as optional parameter in case multiple Redis-Clusters need to be launched for the same project/environment, [#100](https://github.com/dbl-works/terraform/pull/100)

## IAM Management
- added multiple new modules under `./iam` for sane access control, [#95](https://github.com/dbl-works/terraform/pull/95)

## ECS
- fixed an issue where too many ports are opened up in some cases, [#103](https://github.com/dbl-works/terraform/pull/103)

## RDS & Stack
- allow launching a stack with VPC peering without an RDS read replica, [#103](https://github.com/dbl-works/terraform/pull/103)

## S3
- Add Cross Region Replication for S3 :warning: to upgrade, you might need to remove/import the S3 buckets from your terraform state due internal changes in the module ( find detailed instructions in the PR description ), [#101](https://github.com/dbl-works/terraform/pull/101)

## Elasticache
- allow passing multiple CIDR blocks to the security group for access from multiple VPCs, [#105](https://github.com/dbl-works/terraform/pull/105)



## [v2022.07.08]

## VPN
- `availability_zones` can now be explicitly passed into the module, [#98](https://github.com/dbl-works/terraform/pull/98)

## KMS Key Replica
- new module that allows to create a replica of a KMS key in another region, [#97](https://github.com/dbl-works/

## RDS
- added the option to create a read-replica, [#97](https://github.com/dbl-works/terraform/pull/97)
- allow to create unique names across regions by setting `regional`, [#97](https://github.com/dbl-works/terraform/pull/97)

## VPC-Peering
- added a new module `vpc-peering` to create a VPC Peering Resource, [#97](https://github.com/dbl-works/terraform/pull/97)

## Stack & Cloudflare
- fixed issues when setting up a bastion, [#93](https://github.com/dbl-works/terraform/pull/93)
- added the option to launch a stack with a RDS read-replica, [#97](https://github.com/dbl-works/terraform/pull/97)



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
