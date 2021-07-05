# Terraform Module: secrets

Used for creating a new secret.


## Usage

```terraform
module "secrets" {
  source = "github.com/dbl-works/terraform//secrets"

  project     = "someproject"
  environment = "staging"
  application = "rails"
}
```

the name of the secret will be `project/application/environment-XXX` with `XXX` being a random string added by AWS.
Currently, rotation is not yet implemented. This would require a `aws_secretsmanager_secret_rotation` resource and a AWS Lambda function that can then trigger the rotation.

Optionally, blank key/value pairs can already be created:

```terraform
variable "rails-default" {
  default = {
    RAILS_MASTER_KEY = "replace-me"
    DATABASE_URL     = "replace-me"
    REDIS_URL        = "replace-me"
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "rails-default" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.rails-default)
}
```

Read more [here](# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version).


## Outputs

- `secrets_arn`
