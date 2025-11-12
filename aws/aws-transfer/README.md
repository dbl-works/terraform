# Terraform Module: AWS Transfer

A repository for setting up AWS Transfer with users


## Usage

```terraform
module "aws-transfer" {
  source = "github.com/dbl-works/terraform//aws/aws-transfer?ref=main"

  project = local.project
  environment = local.environment

  # Optional
  s3_bucket_name = "aws-transfer-bucket"
  identity_provider_type = "SERVICE_MANAGED"
  server_domain = "S3"
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
      s3_prefix = "my-folder"
      s3_bucket_name = "aws-transfer-bucket" # required if s3_bucket_name is null
      s3_kms_arn =  "arn::kms::xxxxxxxx" # required if s3_bucket_name is null and the bucket is private
    }
  }
  home_directory_type = "LOGICAL"
}
```
