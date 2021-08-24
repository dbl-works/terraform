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


## Initial Outline configuration after first launch

```shell
ssh -i workspaces/proxy/outline-server-ssh.pem ubuntu@{eip} "sudo cat /opt/outline/access.txt"
```

Copy the output to the following format, then paste into outline manager.

```json
{
  "apiUrl": "https://0.0.0.0:1234/xxx",
  "certSha256": "xxx",
}
```

*NOTE:* The IP address in all the connection links will be wrong initially. This should be fixed vai the Outline API (to be documented).




## Create EIP

You need to create the EIP manually in the account first, then hard code in the value for the module config.

https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#Addresses:



## Create SSH Key

You need to create a keypair in EC2 manually and have access to this locally (we store these in 1password).

https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:



## Custom Domain

By default the VPN will launch with just the public IP address (EIP). If you want to access this via a friendly name (e.g. proxy.dbl.works) then you should add a DNS entry (A record) with the EIP as the value for the subdomain you want.

`A proxy.dbl.works. 127.0.0.1`
