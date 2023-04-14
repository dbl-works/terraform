# Terraform Module: AWS Transfer

A repository for setting up AWS Transfer with users


## Usage

```terraform
module "aws-transfer" {
  source = "github.com/dbl-works/terraform//aws-transfer?ref=v2023.03.30"

  project = local.project
  environment = local.environment
  s3_bucket_name = "aws-transfer-bucket"
  s3_prefix = "brussel"

  # Optional
  identity_provider_type = "SERVICE_MANAGED"
  protocols = ["SFTP"]
  endpoint_type = "PUBLIC"
  endpoint_details = {
    address_allocation_ids = [aws_eip.main.id]
    subnet_ids             = [aws_subnet.main.id]
    vpc_id                 = aws_vpc.main.id
  }
  users = {
    Harry = {
      ssh_key = "ssh-public-key-string"
    }
  }
}
```
