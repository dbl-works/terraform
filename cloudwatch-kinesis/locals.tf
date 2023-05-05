locals {
  name           = "${var.project}-${var.environment}"
  log_group_name = "/kinesis/${local.name}"

  s3_output_prefix       = var.s3_output_prefix == null ? "logs/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}" : var.s3_output_prefix
  s3_error_output_prefix = var.s3_error_output_prefix == null ? "errors/${var.environment}/!{timestamp:yyyy-MM/dd/HH}/!{timestamp:yyyy-MM-dd-HH-mm-ss}-${var.environment}-!{firehose:error-output-type}" : var.s3_error_output_prefix
}
