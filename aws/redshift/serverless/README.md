# Redshift Serverless

[Docs](https://registry.terraform.io/providers/hashicorp/aws/5.99.0/docs/resources/redshiftserverless_workgroup)

## Usage

Pass in VPC, subnet, RDS ARN, and ECS security group/role variables from your existing modules.
Provision Redshift Serverless, endpoint access, zero-ETL integration, and security/IAM for ECS access.

```terraform
module "redshift_serverless" {
  source                     = "github.com/dbl-works/terraform//redshift/serverless?ref=v2021.07.01"

  region                     = "eu-central-1"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnets
  project                    = "someproject"
  environment                = "staging"

  source_rds_arn              = module.rds.database_identifier
  ecs_tasks_security_group_id = module.ecs.tasks_security_group_id
  ecs_task_role_arn           = module.ecs.task_role_arn
}
```

## Implementation Plan (with Existing ECS, RDS, and VPC)

### Variables to Pass In

- **ECS (already in place)**
  - `ecs_tasks_security_group_id`: Security group ID for ECS tasks (to allow Redshift access)
  - (Optional) `ecs_task_role_arn`: IAM role ARN for ECS tasks (for IAM authentication to Redshift)

- **RDS (already in place)**
  - `source_rds_arn`: ARN of the RDS instance (for zero-ETL integration)
  - (Optional) `source_rds_security_group_id`: Security group ID for RDS (if needed for networking rules)

- **VPC (already in place)**
  - `vpc_id`: VPC ID where all resources are deployed
  - `subnet_ids`: List of private subnet IDs for Redshift Serverless endpoint access

---

### Terraform Resources

- `aws_redshiftserverless_namespace`:
  Defines the Redshift Serverless logical database environment.

- `aws_redshiftserverless_workgroup`:
  Configures compute resources and networking for Redshift Serverless.

- `aws_redshiftserverless_endpoint_access`:
  Creates a VPC endpoint for private access to Redshift Serverless.

- `aws_rds_integration`:
  Sets up the zero-ETL pipeline from RDS to Redshift Serverless.

- `aws_security_group`:
  Allows ECS tasks to connect to Redshift Serverless (ingress on port 5439).
  - Reference `ecs_tasks_security_group_id` for ingress rules.

- `aws_iam_policy` & `aws_iam_role_policy_attachment`:
  Grants ECS task role permission to authenticate to Redshift (IAM auth).
  - Reference `ecs_task_role_arn` if using IAM authentication.
