resource "aws_transfer_user" "main" {
  for_each  = var.users
  server_id = aws_transfer_server.main.id
  user_name = each.key
  role      = module.aws-transfer-iam-role[each.key].role_arn

  home_directory_type = var.home_directory_type
  home_directory      = var.home_directory_type == "PATH" ? "/${var.s3_bucket_name}/${each.value["s3_prefix"]}" : null

  dynamic "home_directory_mappings" {
    for_each = home_directory_mappings ? [] : [{ target = "/${var.s3_bucket_name}/${each.value["s3_prefix"]}" }]
    content {
      entry  = "/"
      target = home_directory_mappings.target
    }
  }

  tags = {
    Name        = each.key
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_transfer_ssh_key" "main" {
  for_each = var.users

  server_id = aws_transfer_server.main.id
  user_name = each.key
  body      = each.value["ssh_key"]
  depends_on = [
    aws_transfer_user.main
  ]
}
