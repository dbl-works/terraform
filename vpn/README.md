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

We cannot currently run ssh commands using Terraform, so we need to manually configure Outline after it's online. The easiest way to do this is to run the following command which is provided by Terraform output

```shell
tf -chdir=workspaces/my-projects-vpn output -raw outline-access-command | sh
```

Copy the output to the following format, then paste into outline manager.

```json
{
  "apiUrl": "https://127.0.0.1:1234/xxx",
  "certSha256": "xxx",
}
```

The next step is to configure the hostname/IP that will be used for generating access keys. By default, this will be the one created inside the packer AMI. Using the same `apiUrl` as above, run the following command:

```shell
export API_URL=https://0.0.0.0:1234/xxx
curl --insecure -X PUT -d '{"hostname":"127.0.0.1"}' -H "Content-Type: application/json" $API_URL/server/hostname-for-access-keys
```

To verify everything is setup correctly, you can view the current server status:

```shell
curl --insecure $API_URL/server
```

Find the full documentation of Outline's API [here](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/shadowbox/server/api.yml)



## Create EIP

You need to create the EIP manually in the account first, then hard code in the value for the module config.

https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#Addresses:



## Create SSH Key

You need to create a keypair in EC2 manually and have access to this locally (we store these in 1Password).

https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=eu-central-1#KeyPairs:



## Custom Domain

By default the VPN will launch with just the public IP address (EIP). If you want to access this via a friendly name (e.g. proxy.dbl.works) then you should add a DNS entry (A record) with the EIP as the value for the subdomain you want.

`A proxy.dbl.works. 127.0.0.1`
