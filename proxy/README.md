# Terraform Module: Proxy

A reopsitory for setting up a proxy to allow accessing ressources through a fixed IP.
Connecting to the SSH Proxy can be done e.g. via setting up a SSH tunnel, then proxying all network traffic through this tunnel. Authentication can be based on SSH keys that are whitelisted on bastion service.


## Usage

```terraform
#
# :warning: the certificate MUST be created and manually validated before any depending ressources
#
module "ssl-certificate" {
  source = "github.com/dbl-works/terraform//certificate?ref=v2021.07.05"

  project     = "ssh-proxy"
  environment = "production"
  domain_name = "proxy-${aws-account-alias}.dbl.works"
}


module "proxy" {
  source = "github.com/dbl-works/terraform//nat?ref=v2021.07.12"

  account_id          = "123456"
  account_alias       = "aws-account-alias" # ???
  ssl_certificate_arn = "arn:aws:acm:...:certificateXXX"
  environment         = "production"
  public_ips = [
    "123.123.123.123",
    "234.234.234.234",
    "134.134.134.134",
  ]

  # optional
  project           = "ssh-proxy"
  health_check_path = "/healthz"
  cidr_block        = "10.6.0.0/16"
  availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
}
```

`public_ips` is a list of Elastic IPs that have to belong to the same AWS account that hosts the proxy.

## Outputs
_none_
