variable "environment" {}
variable "project" {}
variable "region" {}
variable "ses_from_email" {
  description = "Amazon SES Sender's email address or sender's display name with their email address"
}
variable "ses_arn" {
  description = "Amazon SES Amazon Resources Name"
}
