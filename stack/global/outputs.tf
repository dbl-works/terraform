output "ip_sets" {
  value = module.global-accelerator[0].ip_sets
}

output "dns_name" {
  value = module.global-accelerator[0].dns_name
}
