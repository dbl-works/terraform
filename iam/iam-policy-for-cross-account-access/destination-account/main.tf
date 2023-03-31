resource "aws_iam_role" "assume_role" {
  name = "assume_role"

  max_session_duration = var.max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { "AWS" : "arn:aws:iam::${var.bastion_aws_account_id}:root" }
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cross_account_role_policy" {
  role       = aws_iam_role.assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/${var.policy_name}"
}
