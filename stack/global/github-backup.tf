module "github-backup" {
  count = var.github_backup_config == null ? 0 : 1

  source = "../../github-backup"

  github_org = var.github_backup_config.github_org

  # optional
  environment        = var.environment
  interval_value     = var.github_backup_config.interval_value
  interval_unit      = var.github_backup_config.interval_unit
  ruby_major_version = var.github_backup_config.ruby_major_version
  timeout            = var.github_backup_config.timeout
  memory_size        = var.github_backup_config.memory_size
}
