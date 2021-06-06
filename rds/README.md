# Terraform Module: RDS

Used for creating and configuring databases and their networking.


## Usage

```
module "db" {
  source = "github.com/dbl-works/terraform//rds"

  vpc_id = "vpc-123"
  project = "someproject"
  environment = "staging"
  password = "xxx"
  subnet_ids = [ "subnet-1", "subnet-2" ]
  kms_key_arn = "arn:aws:kms:eu-central-1:12345678:key/xxx-xxx"
}
```


## RDS Engine Versions

To get a list of RDS versions, you can use the following command:

```shell
aws rds describe-db-engine-versions --engine postgres --engine-version 13 --region us-east-1 --endpoint https://rds.us-east-1.amazonaws.com --output text --query 'DBEngineVersions[*].{Engine:Engine,EngineVersion:EngineVersion}'
```
