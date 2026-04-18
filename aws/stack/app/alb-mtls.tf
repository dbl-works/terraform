module "alb_mtls" {
  source = "../../alb-mtls"
  count  = var.alb_mtls_ca_certificates_pem != null ? 1 : 0

  project             = var.project
  environment         = var.environment
  ca_certificates_pem = var.alb_mtls_ca_certificates_pem
}
