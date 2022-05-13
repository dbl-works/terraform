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

  grant_read_access_to_s3_arns  = []
  grant_write_access_to_s3_arns = []

  grant_read_access_to_sqs_arns = []
  grant_write_access_to_sqs_arns = []

  custom_policies = []
}
```

`allow_internal_traffic_to_ports` allow traffic to given ports within the cluster, e.g. to call an internal service like a PDF renderer.

## Health checks

If you run apps in many different cloud environments (e.g. Heroku, RKE, EKS, ECS, Lambda, Cloud66), you want consistent health checks implemented for consistency.

Kubernetes have an excellent methodology where they name their health check `/livez` and `/readyz` to not conflict with any other potential resource endpoint.
The below documentation mentions `/healthz` (and this is also what we used previoulsy) but since Kubernetes 1.16 deprecated this endpoint, this terminology will be phased out.

[https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request)

We should aim to have the following endpoint(s) implemented on all projects to work across any deployed environment:

- `GET /livez`
- `GET /readyz` (optional, but useful for some projects)
