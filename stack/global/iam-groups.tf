locals {
  group_names = [
    "administrators",
    "iam-managers",
    "engineer",
  ]
}

resource "aws_iam_group" "main" {
  for_each = toset(local.group_names)
  name     = each.value
  path     = "/"
}

# Assign groups to created user
resource "aws_iam_user_group_membership" "memberships" {
  for_each = var.users
  user     = each.value["iam"]
  groups   = each.value["groups"]
  depends_on = [
    aws_iam_group.main,
  ]
}

resource "aws_iam_user" "user" {
  for_each = var.users
  name     = each.value["iam"]
  tags = {
    name                                 = each.value["name"]
    github                               = each.value["github"]
    staging-developer-access-projects    = join(":", try(each.value["project_access"]["developer"]["staging"], []))
    staging-admin-access-projects        = join(":", try(each.value["project_access"]["admin"]["staging"], []))
    production-developer-access-projects = join(":", try(each.value["project_access"]["developer"]["production"], []))
    production-admin-access-projects     = join(":", try(each.value["project_access"]["admin"]["production"], []))
  }
}
