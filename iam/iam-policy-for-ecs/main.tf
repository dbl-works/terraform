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

  region = "eu-central-1"
}

data "aws_iam_policy_document" "ecs_list" {
  statement {
    sid = "AllowListAccessToECS"
    actions = [
      "ecs:DescribeClusters",
      "ecs:ListClusters"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowListAccessToECSRelevantResources"
    actions = [
      "cloudwatch:*",
      "logs:Describe*",
      "logs:Get*",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_read" {
  statement {
    sid = "AllowReadAccessToECS"
    actions = [
      "ecs:Describe*",
      "ecs:Get*",
      "ecs:List*"
    ]
    resources = flatten(concat(
      [
        for project in local.staging_read_access_projects : [
          "arn:aws:ecs:*:*:task-definition/*",
          "arn:aws:ecs:*:*:cluster/${project}-staging",
          "arn:aws:ecs:*:*:container/${project}-staging/*",
          "arn:aws:ecs:*:*:container-instance/${project}-staging/*",
          "arn:aws:ecs:*:*:service/${project}-staging/*",
          "arn:aws:ecs:*:*:task/${project}-staging/*"
        ]
      ],
      [
        for project in local.production_read_access_projects : [
          "arn:aws:ecs:*:*:task-definition/*",
          "arn:aws:ecs:*:*:cluster/${project}-production",
          "arn:aws:ecs:*:*:container/${project}-production/*",
          "arn:aws:ecs:*:*:container-instance/${project}-production/*",
          "arn:aws:ecs:*:*:service/${project}-production/*",
          "arn:aws:ecs:*:*:task/${project}-production/*"
        ]
      ]
    ))
  }
}

data "aws_iam_policy_document" "ecs_write" {
  statement {
    sid = "AllowWriteAccessToECS"
    actions = [
      "ecs:*",
    ]
    resources = flatten(concat(
      [
        for project in local.staging_write_access_projects : [
          "arn:aws:ecs:*:*:task-definition/*",
          "arn:aws:ecs:*:*:cluster/${project}-staging",
          "arn:aws:ecs:*:*:container/${project}-staging/*",
          "arn:aws:ecs:*:*:container-instance/${project}-staging/*",
          "arn:aws:ecs:*:*:service/${project}-staging/*",
          "arn:aws:ecs:*:*:task/${project}-staging/*"
        ]
      ],
      [
        for project in local.production_write_access_projects : [
          "arn:aws:ecs:*:*:task-definition/*",
          "arn:aws:ecs:*:*:cluster/${project}-production",
          "arn:aws:ecs:*:*:container/${project}-production/*",
          "arn:aws:ecs:*:*:container-instance/${project}-production/*",
          "arn:aws:ecs:*:*:service/${project}-production/*",
          "arn:aws:ecs:*:*:task/${project}-production/*"
        ]
      ]
    ))
  }
}

data "aws_iam_policy_document" "ecs_taggable_ssm" {
  statement {
    sid = "AllowSsmStartSessionInStaging"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "*",
      "arn:aws:ssm:${local.region}:*:document/AmazonECS-ExecuteInteractiveCommand"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = ["staging"]
    }

    condition {
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/staging-admin-access-projects}"]
    }
  }

  statement {
    sid = "AllowSsmStartSessionInProduction"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "*",
      "arn:aws:ssm:${local.region}:*:document/AmazonECS-ExecuteInteractiveCommand"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = ["production"]
    }

    condition {
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/production-admin-access-projects}"]
    }
  }

  statement {
    sid = "AllowSsmDescribeSessionInStaging"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    # TODO: Verify whether aws:username format is correct here
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = ["staging"]
    }

    condition {
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/staging-admin-access-projects}"]
    }
  }

  statement {
    sid = "AllowSsmDescribeSessionInProduction"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    # TODO: Verify whether aws:username format is correct here
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = ["production"]
    }

    condition {
      # Using StringLike here because currently tag cannot take multivalue
      # We can only create a custom multivalue structure in the single value
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags.html
      test     = "StringLike"
      variable = "aws:ResourceTag/Project"
      values   = ["&{aws:PrincipalTag/production-admin-access-projects}"]
    }
  }
}

data "aws_iam_policy_document" "ecs_ssm" {
  statement {
    sid = "AllowSsmTerminateSession"
    actions = [
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:DescribeInstanceProperties",
      "ec2:DescribeInstances"
    ]
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_iam" {
  statement {
    sid = "AllowIamPassRole"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    sid = "AllowIamListRole"
    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfiles",
      "iam:ListRoles"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowEcsInstanceRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ecsInstanceRole*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com",
        "ec2.amazonaws.com.cn"
      ]
    }
  }

  statement {
    sid = "AllowEcsAutoscaleRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ecsAutoscaleRole*"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "application-autoscaling.amazonaws.com",
        "application-autoscaling.amazonaws.com.cn"
      ]
    }
  }

  statement {
    sid = "AllowCreateServiceLinkedRole"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values = [
        "autoscaling.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs.application-autoscaling.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "ecs_policy" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.ecs_list.json, data.aws_iam_policy_document.ecs_taggable_ssm.json],
    (length(local.read_access_projects) == 0 ? [] : [data.aws_iam_policy_document.ecs_read.json]),
    (length(local.write_access_projects) == 0 ? [] : [data.aws_iam_policy_document.ecs_write.json, data.aws_iam_policy_document.ecs_ssm.json, data.aws_iam_policy_document.ecs_iam.json])
  )
}

resource "aws_iam_policy" "ecs" {
  name        = "ECSAccessFor${title(var.username)}"
  path        = "/"
  description = "Allow access to ECS resources for ${var.username}"

  policy = data.aws_iam_policy_document.ecs_policy.json
}

resource "aws_iam_user_policy_attachment" "user" {
  user       = data.aws_iam_user.main.user_name
  policy_arn = aws_iam_policy.ecs.arn
}
