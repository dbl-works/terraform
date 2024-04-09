module "defender" {
  count = var.enable_defender ? 1 : 0

  source = "../../defender"
}
