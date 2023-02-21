resource "aws_ecr_repository" "main" {
  name                 = var.project
  image_tag_mutability = var.mutable ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = var.project
  }
}

locals {
  protect_rules = [for tag in var.protected_tags : {
    "rulePriority" : index(var.protected_tags, tag) + 1,
    "description" : "Protect ${tag}",
    "selection" : {
      "tagStatus" : "tagged",
      "tagPrefixList" : [tag],
      "countType" : "imageCountMoreThan",
      "countNumber" : 1
    },
    "action" : {
      "type" : "expire"
    }
  }]
}

resource "aws_ecr_lifecycle_policy" "expiry_policy" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode(
    {
      "rules" : flatten([
        local.protected_tags,
        {
          "rulePriority" : length(var.protect_tags) + 1,
          "description" : "Expire images older than ${var.valid_days} days",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "sinceImagePushed",
            "countUnit" : "days",
            "countNumber" : var.valid_days
          },
          "action" : {
            "type" : "expire"
          }
        }
      , var.ecr_lifecycle_policy_rules])
    }
  )
}
