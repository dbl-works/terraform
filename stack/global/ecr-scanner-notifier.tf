module "ecr-scanner-notifier" {
  count = var.ecr_scanner_notifier_config == null ? 0 : 1

  source = "../../slack/ecr-scanner-notifier"

  project           = var.project
  slack_webhook_url = var.ecr_scanner_notifier_config.slack_webhook_url
  slack_channel     = var.ecr_scanner_notifier_config.slack_channel
}
