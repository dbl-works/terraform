# Terraform Module: Proxy

A reopsitory for setting up a proxy to allow accessing ressources through a fixed IP.
Connecting to the SSH Proxy can be done e.g. via setting up a SSH tunnel, then proxying all network traffic through this tunnel. Authentication can be based on SSH keys that are whitelisted on bastion service.

To allow certain SSH keys on the bastion server, follow the instructions of [this repo](https://github.com/dbl-works/bastion), which hosts a Dockerfile to build an appropriate image.

@TODO: document how to setup DNS records on Cloudflare


## Usage

```terraform
module "proxy" {
  source = "github.com/dbl-works/terraform//proxy?ref=v2021.07.12"

  account_id  = "123456"
  environment = "production"
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

- `public_ips` is a list of Elastic IPs that have to belong to the same AWS account that hosts the proxy.
- after creating the proxy, .... @TODO: how to setup DNS record for a lookup

## Outputs
_none_
