resource "aws_iam_policy" "main" {
  name        = "assume-role-policy-for-account-${var.destination_aws_account_id}"
  description = "Allow assuming ${var.destination_iam_role_name} role in AWS Account ID: ${var.destination_aws_account_id}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${var.destination_aws_account_id}:role/${var.destination_iam_role_name}"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "assume_role" {
  count = length(var.usernames)

  user       = var.usernames[count.index]
  policy_arn = aws_iam_policy.main.arn
}
