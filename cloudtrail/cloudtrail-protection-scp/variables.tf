variable "scp_target_account_ids" {
  description = "The Root ID, Organizational Unit ID, or AWS Account ID to apply SCPs."
  type        = list(string)
}

variable "log_ingestor_account_id" {
  description = "The AWS Account ID of the account that will ingest CloudTrail logs."
  type        = string
}
