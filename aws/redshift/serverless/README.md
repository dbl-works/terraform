# Redshift Serverless

[Docs](https://registry.terraform.io/providers/hashicorp/aws/5.99.0/docs/resources/redshiftserverless_workgroup)

## Usage

```terraform
module "redshift_serverless" {
  source = "github.com/dbl-works/terraform//redshift/serverless?ref=v2021.07.01"

  region      = "eu-central-1"
  project     = "someproject"
  environment = "staging"

  # Authentication
  admin_password = var.redshift_password  # For application access (store in AWS Secrets Manager)

  # VPC Configuration
  vpc_id     = module.vpc.id
  subnet_ids = module.vpc.subnet_private_ids

  # RDS Configuration (for zero-ETL)
  source_rds_arn               = module.rds.database_arn
  source_rds_security_group_id = module.rds.database_security_group_id

  # ECS Configuration
  ecs_security_group_id = module.ecs.ecs_security_group_id
}

# Your application connects using password from Secrets Manager
# Developers connect via bastion host using IAM authentication
```

In a Ruby app:

```ruby
connection = PG.connect(
  host: "module.redshift_serverless.endpoint",
  port: 5439,
  dbname: "mydb",
  user: "admin",
  password: "var.redshift_password",
)
```

### Module Outputs

- `endpoint`: Redshift Serverless endpoint for connections
- `database_name`: Name of the database
- `admin_username`: Admin username for password authentication
- `iam_role_arn_admin`: IAM role ARN for admin access (human users)
- `iam_role_arn_readonly`: IAM role ARN for readonly access (human users)

## Implementation Plan

### Authentication Strategy

- **Applications (ECS)**: Use password authentication with credentials stored in AWS Secrets Manager
- **Human Users (Developers)**: Use IAM authentication via bastion host running in ECS

### Variables to Pass In

- **Authentication**
  - `admin_password`: Password for the admin user (applications will use this)

- **VPC (already in place)**
  - `vpc_id`: From `module.vpc.id`
  - `subnet_ids`: From `module.vpc.subnet_private_ids`

- **RDS (already in place)**
  - `source_rds_arn`: From `module.rds.database_arn`
  - `source_rds_security_group_id`: From `module.rds.database_security_group_id`

- **ECS (already in place)**
  - `ecs_security_group_id`: From `module.ecs.ecs_security_group_id`

---

### Terraform Resources

- `aws_redshiftserverless_namespace`:
  Defines the Redshift Serverless logical database environment with admin credentials.

- `aws_redshiftserverless_workgroup`:
  Configures compute resources and networking for Redshift Serverless.

- `aws_redshiftserverless_endpoint_access`:
  Creates a VPC endpoint for private access to Redshift Serverless.

- `aws_rds_integration`:
  Sets up the zero-ETL pipeline from RDS to Redshift Serverless.

- `aws_security_group` (for Redshift):
  Creates a new security group for Redshift with:
  - Ingress from `ecs_security_group_id` on port 5439 (for both apps and bastion)
  - Ingress from `source_rds_security_group_id` (for zero-ETL)

- `aws_iam_group` and `aws_iam_policy` (for human access):
  Creates IAM groups and policies for developers to connect via bastion host:
  - `redshift-serverless-admin`: Full access for admin users
  - `redshift-serverless-readonly`: Read-only access for developers
  - Policies grant `redshift-serverless:GetCredentials` for IAM authentication

---

### Note

Applications should retrieve the Redshift password from AWS Secrets Manager at runtime. Human users should connect through a bastion host deployed in ECS using IAM authentication, similar to the RDS access pattern.
