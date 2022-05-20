locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.terraform.secret_string
  )
}

data "aws_secretsmanager_secret_version" "terraform" {
  secret_id = module.secrets["terraform"].id
}
