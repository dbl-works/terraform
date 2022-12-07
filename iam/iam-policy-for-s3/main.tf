locals {
  # [
  #   {
  #       "name"        = "facebook-production"
  #       "env"         = "production"
  #     }
  #   },
  #   {
  #       "name"        = "facebook-staging"
  #       "env"         = "staging"
  #     }
  #   },
  #   {
  #       "name"        = "metaverse-staging"
  #       "env"         = "staging"
  #     }
  #   },
  # ]
  developer_access_projects = flatten([
    for env, project_names in try(var.project_access["developer"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env
      }
    ]
  ])

  admin_access_projects = flatten([
    for env, project_names in try(var.project_access["admin"], {}) : [
      for project_name in project_names : {
        "name"        = "${project_name}-${env}"
        "environment" = env
      }
    ]
  ])

  skip_aws_iam_policy_s3 = var.allow_listing_s3 == false && length(developer_access_projects) == 0 && length(admin_access_projects) == 0
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
    resources = [
      for project in distinct(concat(local.developer_access_projects, local.admin_access_projects)) :
      "arn:aws:s3:::${project.name}-storage"
    ]
  }
}

data "aws_iam_policy_document" "s3_full" {
  statement {
    sid = "AllowWriteAccessToS3"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:PutObjectVersionAcl",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]

    resources = flatten([
      for project in distinct(concat(local.developer_access_projects, local.admin_access_projects)) :
      ["arn:aws:s3:::${project.name}-storage", "arn:aws:s3:::${project.name}-storage/*"]
    ])
  }
}

data "aws_iam_policy_document" "s3_policy" {
  source_policy_documents = concat(
    (var.allow_listing_s3 ? [data.aws_iam_policy_document.s3_list.json] : []),
    (length(local.developer_access_projects) == 0 ? [] : [data.aws_iam_policy_document.s3_read.json]),
    (length(local.admin_access_projects) == 0 ? [] : [data.aws_iam_policy_document.s3_full.json])
  )
}

resource "aws_iam_policy" "s3" {
  count = local.skip_aws_iam_policy_s3 ? 0 : 1

  name        = replace("S3AccessFor${title(var.username)}", "/[^0-9A-Za-z]/", "")
  path        = "/"
  description = "Allow access to s3 resources for ${var.username}"

  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_user_policy_attachment" "user" {
  count = local.skip_aws_iam_policy_s3 ? 0 : 1

  user       = var.username
  policy_arn = aws_iam_policy.s3[0].arn
}
