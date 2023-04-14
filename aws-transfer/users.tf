data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "aws-transfer-family-roles-for-${var.project}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.id
  policy_arn = module.s3-storage.policy_arn
}

resource "aws_transfer_user" "main" {
  for_each  = var.users
  server_id = aws_transfer_server.main.id
  user_name = each.key
  role      = aws_iam_role.main.arn

  home_directory = "/${var.s3_bucket_name}/${each.value["s3_prefix"]}"

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
}
