resource "aws_kms_alias" "a" {
  name = "alias/${var.project}/${var.environment}/${var.alias}"
  target_key_id = aws_kms_key.key.key_id
}
