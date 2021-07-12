# Terraform Module: Proxy

A reopsitory for setting up a proxy to allow accessing ressources through a fixed IP.
Connecting to the SSH Proxy can be done e.g. via setting up a SSH tunnel, then proxying all network traffic through this tunnel. Authentication can be based on SSH keys that are whitelisted on bastion service.

To allow certain SSH keys on the bastion server, follow the instructions of [this repo](https://github.com/dbl-works/bastion), which hosts a Dockerfile to build an appropriate image.


## Usage

```terraform
#
# :warning: the certificate MUST be created and manually validated before any depending ressources
#
module "ssl-certificate-proxy" {
  source = "github.com/dbl-works/terraform//certificate?ref=v2021.07.12"

  project                 = "ssh-proxy"
  environment             = "production"
  domain_name             = "proxy-${aws-account-alias}.dbl.works"
  add_wildcard_subdomains = false
}


module "proxy" {
  source = "github.com/dbl-works/terraform//proxy?ref=v2021.07.12"

  account_id          = "123456"
  ssl_certificate_arn = module.ssl-certificate-proxy.arn # "arn:aws:acm:...:certificateXXX"
  environment         = "production"
  public_ips = [
    "123.123.123.123",
    "234.234.234.234",
    "134.134.134.134",
  ]

  # optional
  project           = "ssh-proxy"
  health_check_path = "/healthz" # Bastion!
  cidr_block        = "10.6.0.0/16"
  availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
}
```

Add to your `outputs.tf`:

```terraform
output "cloudflare_domain_validation_information_proxy" {
  value       = module.ssl-certificate-proxy.domain_validation_information
  description = "Used to complete certificate validation in e.g. Cloudflare."
}

output "certificate_arn_proxy" {
  value       = module.ssl-certificate-proxy.arn
  description = "To be passed to the proxy module."
}
```

- `public_ips` is a list of Elastic IPs that have to belong to the same AWS account that hosts the proxy.
- ensure, to first create and validate the SSL certificate, then wait for the validation to finish, then apply the proxy
- after creating the proxy, set up a CNAME record to point the `domain_name` to the ECS cluster

## Outputs
_none_
