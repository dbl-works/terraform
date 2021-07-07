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
