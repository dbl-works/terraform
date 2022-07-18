# Terraform Module: kms-key-replica

Replica of a KMS key for multi-regional KMS keys. E.g. if you have read-replicas of an RDS instance in multiple geo-regions that use an KMS key for encryption.



## Usage

```terraform
module "kms-key-replica" {
  source = "github.com/dbl-works/terraform//kms-key-replica?ref=v2021.07.01"

  # Required
  master_kms_key_arn = "arn:aws:kms:${var.master_region}:${var.acccount_id}:key/mrk-XXX" # NOTE: multi region keys start with "mrk"
  environment        = "staging"
  project            = "someproject"
  alias              = "rds"
}
```
