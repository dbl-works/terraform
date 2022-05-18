module "certificate" {
  source = "github.com/dbl-works/terraform//certificate?ref=${var.module_version}"

  project     = var.project
  environment = var.environment
  domain_name = var.domain_name

  # Optional
  add_wildcard_subdomains = var.add_wildcard_subdomains
}
