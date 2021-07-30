# Terraform Module: ECS Cluster

Create a compute cluster for hosting docker based apps.


## Usage

```terraform
module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.05"

  project            = local.project
  environment        = local.environment
  vpc_id             = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids  = module.vpc.subnet_private_ids
  secrets_arns       = []
  kms_key_arns       = []

  # optional
  health_check_path = "/healthz"
  certificate_arn   = module.ssl-certificate.arn # requires a `certificate` module to be created separately

  allow_internal_traffic_to_ports = []

  allowlisted_ssh_ips = [
    local.cidr_block,
    "XX.XX.XX.XX/32", # e.g. a VPN
  ]

  allowlisted_buckets = []
}
```

`allow_internal_traffic_to_ports` allow traffic to given ports within the cluster, e.g. to call an internal service like a PDF renderer.
