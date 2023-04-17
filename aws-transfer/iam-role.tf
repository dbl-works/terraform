module "aws-transfer-iam-role" {
  source = "./iam-role"

  for_each = var.users

  username       = each.key
  s3_prefix      = each.value["s3_prefix"]
  s3_bucket_name = each.value["s3_bucket_name"] == null ? var.s3_bucket_name : each.value["s3_bucket_name"]
  s3_kms_arn     = each.value["s3_kms_arn"] == null ? module.s3-storage[0].kms-key-arn : each.value["s3_kms_arn"]
}
