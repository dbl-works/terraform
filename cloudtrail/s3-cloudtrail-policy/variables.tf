variable "cloudtrail_s3_bucket_name" {
  type        = string
  description = "The name of the AWS S3 bucket for which CloudTrail will store the logs in"
}

variable "cloudtrail_arns" {
  type        = list(string)
  description = "The cloudtrail arns in the log producer accounts"
}
