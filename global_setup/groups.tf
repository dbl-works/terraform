locals {
  group_names = [
    "engineer",
    "humans",
  ]
}

resource "aws_iam_group" "main" {
  for_each = toset(local.group_names)
  name     = each.value
  path     = "/"
}
