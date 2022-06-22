data "aws_iam_user" "main" {
  user_name = var.username
}

locals {
  staging_developer_access_projects    = try(data.aws_iam_user.main.tags.staging-developer-access-projects, "")
  staging_admin_access_projects        = try(data.aws_iam_user.main.tags.staging-admin-access-projects, "")
  production_developer_access_projects = try(data.aws_iam_user.main.tags.production-developer-access-projects, "")
  production_admin_access_projects     = try(data.aws_iam_user.main.tags.production-admin-access-projects, "")

  staging_read_access_projects = distinct(compact(concat(
    split(":", local.staging_developer_access_projects),
    split(":", local.staging_admin_access_projects),
  )))

  production_read_access_projects = distinct(compact(concat(
    split(":", local.production_admin_access_projects),
    split(":", local.production_developer_access_projects),
  )))

  staging_write_access_projects = distinct(compact(split(":", local.staging_admin_access_projects)))

  production_write_access_projects = distinct(compact(split(":", local.production_admin_access_projects)))

  read_access_projects = concat(
    local.staging_read_access_projects,
    local.production_read_access_projects
  )

  write_access_projects = concat(
    local.staging_write_access_projects,
    local.production_write_access_projects
  )
}

data "aws_iam_policy_document" "s3_list" {
  statement {
    sid = "AllowListAccessToS3"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["arn:aws:s3:::*"]
  }

}

data "aws_iam_policy_document" "s3_read" {
  statement {
    sid = "AllowReadAccessToS3"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = concat(
      [for project in local.staging_read_access_projects : "arn:aws:s3:::${project}-staging-storage"],
      [for project in local.production_read_access_projects : "arn:aws:s3:::${project}-production-storage"]
    )
  }
}

data "aws_iam_policy_document" "s3_write" {
  statement {
    sid = "AllowWriteAccessToS3"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:PutObjectVersionAcl",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]
    resources = flatten(concat(
      [for project in local.staging_write_access_projects : ["arn:aws:s3:::${project}-staging-storage", "arn:aws:s3:::${project}-staging-storage/*"]],
      [for project in local.production_write_access_projects : ["arn:aws:s3:::${project}-production-storage", "arn:aws:s3:::${project}-production-storage/*"]]
    ))
  }
}

data "aws_iam_policy_document" "s3_policy" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.s3_list.json],
    (length(local.read_access_projects) == 0 ? [] : [data.aws_iam_policy_document.s3_read.json]),
    (length(local.write_access_projects) == 0 ? [] : [data.aws_iam_policy_document.s3_write.json])
  )
}

resource "aws_iam_policy" "s3" {
  name        = "S3AccessFor${title(var.username)}"
  path        = "/"
  description = "Allow access to s3 resources for ${var.username}"

  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_user_policy_attachment" "user" {
  user       = data.aws_iam_user.main.user_name
  policy_arn = aws_iam_policy.s3.arn
}
