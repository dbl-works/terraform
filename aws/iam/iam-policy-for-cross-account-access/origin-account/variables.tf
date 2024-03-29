variable "usernames" {
  type    = list(string)
  default = []
}

variable "destination_aws_account_id" {
  type = string
}

variable "destination_iam_role_name" {
  type = string
}
