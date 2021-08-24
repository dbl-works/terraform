# Terraform Module: VPN

Launches an isolated Outline VPN instance with it's own VPC.



## Usage

```terraform
module "outline-vpn" {
  source = "github.com/dbl-works/terraform//vpn?ref=v2021.08.24"

  account_id  = 12345678
  eip         = "0.0.0.0"
  ami_id      = "ami-07e4ed4c95c385519"
  project     = "dbl"
  environment = "production"
  cidr_block  = "10.0.0.0/16"
  key_name    = "outline-server-ssh"

  # optional
  region        = "eu-central-1"
  instance_type = "t3.micro"
}
```



## Custom Domain

By default the VPN will launch with just the public IP address (EIP). If you want to access this via a friendly name (e.g. proxy.dbl.works) then you should add a DNS entry (A record) with the EIP as the value for the subdomain you want.

`A proxy.dbl.works. 127.0.0.1`
