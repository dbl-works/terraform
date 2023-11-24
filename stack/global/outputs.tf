output "ip_sets" {
  value = var.global_accelerator_config == null ? "" : module.global-accelerator[0].ip_sets
}

output "dns_name" {
  value = var.global_accelerator_config == null ? "" : module.global-accelerator[0].dns_name
}
