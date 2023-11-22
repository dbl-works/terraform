variable "cloudtrail_s3_bucket_name" {
  type        = string
  description = "Specifies the S3 bucket where CloudTrail logs are to be stored ('log-ingestor')."
}

variable "cloudtrail_arns" {
  type        = list(string)
  description = "List of ARNs for CloudTrail trails in the log-producer accounts that will send logs to the specified S3 bucket."
}
