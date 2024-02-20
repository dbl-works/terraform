resource "aws_kms_alias" "a" {
  name          = replace("alias/${var.project}/${var.environment}/${var.alias}", "/[^a-zA-Z0-9:///_-]+/", "-")
  target_key_id = aws_kms_key.key.key_id
}
