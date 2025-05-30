# Redshift Serverless

[Docs](https://registry.terraform.io/providers/hashicorp/aws/5.99.0/docs/resources/redshiftserverless_workgroup)

## Prerequisites

**IMPORTANT**: Before using this module, you must ensure your infrastructure meets AWS requirements.

### VPC and Subnet Requirements

Redshift Serverless has **strict requirements**:
- **Minimum 3 subnets** in **3 different Availability Zones**
- **Minimum 3 free IP addresses per subnet**
- Exception: US West (N. California) requires 3 subnets across only 2 AZs

If your VPC only has 2 subnets (our default), you must create a third subnet in a different AZ before deploying this module.

### RDS Zero-ETL Integration Requirements

RDS zero-ETL integration is **only supported** for:
- **Aurora MySQL** (version 3.05.2+)
- **Aurora PostgreSQL** (version 16.4+)
- **RDS for MySQL** (versions 8.0 and 8.4)

❌ **Not supported**: Regular RDS PostgreSQL instances

Set `create_rds_integration = true` only if your RDS instance supports zero-ETL.

**For Aurora clusters**: Use the **cluster ARN** (from `aws_rds_cluster`), not the instance ARN (from `aws_rds_cluster_instance`). Aurora creates both a cluster and instances, but the zero-ETL integration requires the cluster ARN.

### Password Requirements

The Redshift admin password must meet AWS requirements:
- **Maximum length**: 64 characters
- **Minimum length**: 8 characters
- Must contain at least one uppercase letter, one lowercase letter, and one number
- Can contain printable ASCII characters except `"` (double quote), `\` (backslash), `'` (single quote), `/` (forward slash), `@`, and space

1. Create or update your app secrets in AWS Secrets Manager with the path: `{project}/infra/{environment}`
2. Add a key called `redshift_root_password` with a secure password value

Example AWS CLI command:
```bash
aws secretsmanager put-secret-value \
  --secret-id "myproject/infra/staging" \
  --secret-string '{"redshift_root_password":"your-secure-password-here"}'
```

⚠️ **Warning**: Passwords longer than 64 characters will cause deployment to fail with a validation error.

The module will automatically read this password from your existing app secrets vault.

## Usage

```terraform
module "redshift_serverless" {
  source = "github.com/dbl-works/terraform//aws/redshift/serverless?ref=v2021.07.01"

  region      = "eu-central-1"
  project     = "someproject"
  environment = "staging"

  # VPC Configuration (requires 3 subnets in 3 AZs)
  vpc_id     = module.vpc.id
  subnet_ids = module.vpc.subnet_private_ids  # Must have 3 subnets

  # ECS Configuration
  ecs_security_group_id = module.ecs.ecs_security_group_id

  # RDS Integration (optional - only for Aurora MySQL/PostgreSQL or RDS MySQL)
  create_rds_integration           = false  # Set to true if your RDS supports zero-ETL
  source_rds_arn                   = module.rds.cluster_arn              # Use cluster_arn for Aurora
  source_rds_security_group_id     = module.rds.database_security_group_id
}

# Your application connects using password from Secrets Manager
# Developers connect via bastion host using IAM authentication (see separate IAM module)
```

if you are using the `stack/app` module:

```terraform
module "redshift_serverless" {
  source = "github.com/dbl-works/terraform//aws/redshift/serverless?ref=v2021.07.01"

  region      = local.region
  project     = local.project
  environment = local.environment

  # VPC Configuration (requires 3 subnets in 3 AZs)
  vpc_id     = module.stack.vpc_id
  subnet_ids = module.stack.subnet_private_ids  # Must have 3 subnets

  # ECS Configuration
  ecs_security_group_id = module.stack.ecs_security_group_id

  # RDS Integration (optional - only for Aurora MySQL/PostgreSQL or RDS MySQL)
  create_rds_integration           = false  # Set to true if your RDS supports zero-ETL
  source_rds_arn                   = module.stack.cluster_arn            # Use cluster_arn for Aurora
  source_rds_security_group_id     = module.stack.database_security_group_id
}
```

### Connection URL Setup

After deploying this module, Terraform will output connection URLs. For Ruby applications using the `pg` gem, use the PostgreSQL-compatible connection URL:

```bash
# 1. Get the PostgreSQL-compatible connection URL from Terraform output (it's marked as sensitive)
terraform output -raw connection_url

# 2. Add it to your app secrets
aws secretsmanager put-secret-value \
  --secret-id "myproject/app/staging" \
  --secret-string '{"REDSHIFT_CONNECTION_URL":"postgresql://admin:password@endpoint:5439/database"}'
```

**Note**: Redshift Serverless is PostgreSQL-compatible, so the `postgresql://` connection string format works with the Ruby `pg` gem and other PostgreSQL drivers. For native Redshift JDBC drivers, use `terraform output jdbc_url` instead.

### ECS Deployment Configuration

Add `REDSHIFT_CONNECTION_URL` to your ECS deployment secrets:

```terraform
module "ecs-deploy" {
  source = "github.com/dbl-works/terraform//ecs-deploy/service?ref=main"

  project     = "myproject"
  environment = "staging"

  app_config = {
    name    = "web"
    secrets = [
      "REDSHIFT_CONNECTION_URL"  # Add this to make it available as ENV var
    ]
    # ... other config
  }
}
```

### In your Ruby app:

```ruby
# The connection URL is now available as an environment variable
connection = PG.connect(ENV["REDSHIFT_CONNECTION_URL"])
```

### Module Outputs

- `endpoint`: Redshift Serverless endpoint for connections
- `database_name`: Name of the database
- `admin_username`: Admin username for password authentication
- `connection_url`: PostgreSQL-compatible connection URL (copy this to your app secrets for Ruby pg gem)
- `jdbc_url`: JDBC URL for native Redshift drivers

## Implementation Plan

### Authentication Strategy

- **Applications (ECS)**: Use a complete connection URL containing all credentials, stored in app secrets and made available as environment variables via ECS secrets
- **Human Users (Developers)**: Use IAM authentication via bastion host. Access is controlled by tag-based IAM policies in the separate `iam/iam-policy-for-redshift-serverless` module.

### Variables to Pass In

- **VPC (already in place)**
  - `vpc_id`: From `module.vpc.id`
  - `subnet_ids`: From `module.vpc.subnet_private_ids`

- **RDS (already in place)**
  - `source_rds_arn`: From `module.rds.cluster_arn`
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

---

### Note

**Application Access**: After deploying this module, copy the `connection_url` output to your app secrets as `REDSHIFT_CONNECTION_URL`. Then add `REDSHIFT_CONNECTION_URL` to your ECS deployment secrets to make it available as an environment variable.

**Human Access**: Developers should connect through a bastion host deployed in ECS using IAM authentication. Access is managed through the separate `iam/iam-policy-for-redshift-serverless` module which uses tag-based access control. Users with matching Project/Environment tags automatically get access to Redshift Serverless resources.

**Tagging**: The Redshift Serverless resources (namespace, workgroup) are automatically tagged with Project and Environment values to enable tag-based access control.

**Note**: If you're using the NAT module and adding a third subnet, ensure you're using a version that includes the fix for dynamic subnet creation. Older versions may fail with "Invalid for_each argument" errors.
