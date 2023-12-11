resource "aws_ecs_task_definition" "main" {
  family                   = local.task_definition_name
  container_definitions    = jsonencode(local.container_definitions)
  task_role_arn            = data.aws_iam_role.main.arn
  execution_role_arn       = data.aws_iam_role.main.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.launch_type]
  cpu                      = var.cpu
  memory                   = var.memory

  dynamic "ephemeral_storage" {
    # in terraform, we cannot set the size to the default value, but must at least set it to 21
    # hence we omit this if the default is chosen.
    for_each = var.ephemeral_storage_size_in_gib == 20 ? [] : [{
      size_in_gib = var.ephemeral_storage_size_in_gib
    }]

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  dynamic "volume" {
    for_each = var.volume

    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration == null ? [] : [volume.value.efs_volume_configuration]

        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          authorization_config {
            access_point_id = efs_volume_configuration.value.access_point_id
            iam             = efs_volume_configuration.value.iam
          }
        }
      }
    }
  }

  tags = {
    Name        = local.task_definition_name
    Project     = var.project
    Environment = var.environment
  }

  depends_on = [
    aws_cloudwatch_log_group.ecs_sidecar
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_sidecar" {
  count = length(var.sidecar_config)

  name              = "/${var.sidecar_config[count.index].name}/${local.name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
  }
}
