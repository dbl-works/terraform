output "cloudtrail_arns" {
  value = compact([
    var.enable_management_cloudtrail ? aws_cloudtrail.management[0].arn : null,
    var.enable_data_cloudtrail ? aws_cloudtrail.data[0].arn : null
  ])
}
