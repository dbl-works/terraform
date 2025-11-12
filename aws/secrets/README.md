# Terraform Module: secrets

Used for creating a new secret.



## Usage

```terraform
module "secrets" {
  source = "github.com/dbl-works/terraform//aws/secrets?ref=main"

  project     = "someproject"
  environment = "staging"
  kms_key_id  = "abc-123"

  # Optional
  application = "app"
  description = "Secrets that are not to be stored inside ${var.application}."
}
```

the name of the secret will be `project/application/environment-XXX` with `XXX` being a random string added by AWS.
Currently, rotation is not yet implemented. This would require a `aws_secretsmanager_secret_rotation` resource and a AWS Lambda function that can then trigger the rotation.

You might want to user a more recent `ref`.

Key/value pairs may be created via:

```terraform
variable "rails-default" {
  default = {
    RAILS_MASTER_KEY = "XXX"
    DATABASE_URL     = "XXX"
    REDIS_URL        = "XXX"
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "rails-default" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.rails-default)
}
```

Read more [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version).



## Outputs

- `arn`
- `id`
