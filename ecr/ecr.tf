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

resource "aws_ecr_lifecycle_policy" "expiry_policy" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode(
    {
      "rules" : flatten([
        {
          "rulePriority" : var.valid_days,
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
