# Terraform Module: ECS Cluster

Create a compute cluster for hosting docker based apps.


## Usage

```terraform
module "ecs" {
  source = "github.com/dbl-works/terraform//ecs?ref=v2021.07.05"

  project                         = local.project
  environment                     = local.environment
  vpc_id                          = module.vpc.id
  subnet_private_ids              = module.vpc.subnet_private_ids
  subnet_public_ids               = module.vpc.subnet_private_ids
  secrets_arns                    = []
  kms_key_arns                    = []
  allow_internal_traffic_to_ports = []

  # optional
  health_check_path  = "/healthz"
  certificate_arn    = module.ssl-certificate.arn # requires a `certificate` module to be created separately
  allowlisted_ssh_ips = [
    local.cidr_block,
    "XX.XX.XX.XX/32", # e.g. a VPN
  ]
}
```

`allow_internal_traffic_to_ports` will allow traffic from port `3000` (main entry point) to all given ports; these can be ports for e.g. side car services like a PDF renderer.
