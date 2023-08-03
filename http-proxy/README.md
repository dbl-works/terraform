# Terraform Module: HTTP Proxy

Launches a tiny-proxy based HTTP proxy instance to allow an application server to assume a static IP address for outgoing traffic, e.g. when using a third-party API that requires a static IP address.

⚠️ This is not a great solution for production, but good enough for limited usage. For a more robust solution, consider using a NAT Gateway instead.

## Usage

```terraform
module "http-proxy" {
  source = "github.com/dbl-works/terraform//http-proxy?ref=v2021.08.24"

  project          = "dbl-works"
  environment      = "production"
  public_subnet_id = "subnet-1234567890"
  ami_id           = "ami-0502e817a62226e03" # ubuntu 20.04 which has a free quota
  vpc_id           = "vpc-1234567890"
  cidr_block       = "123.123.123.123/32" # of the VPC in which your application server is running

  # optional
  eip           = "12.34.5.678" # if omitted, a new EIP is allocated
  instance_type = "t3.micro"
  ssh_enabled   = false # switch this to "true" for the initial configuration, but keep it "false" for production
}
```
