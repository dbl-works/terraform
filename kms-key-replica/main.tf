# https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-auth.html
# if we create a RDS read-replica in a different region, we must pass the KMS key ARN to the replica
# so that the replica can read an encrypted master DB. KMS keys by default are only accessible in their
# region, hence we must create a replica of the RDS key.
resource "aws_kms_replica_key" "replica" {
  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = var.master_kms_key_arn

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_kms_alias" "a" {
  name          = replace("alias/${var.project}/${var.environment}/${var.alias}", "/[^a-zA-Z0-9:///_-]+/", "-")
  target_key_id = aws_kms_replica_key.replica.key_id
}
