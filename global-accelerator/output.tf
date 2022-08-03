output "ip_sets" {
  value = aws_globalaccelerator_accelerator.main-accelerator.ip_sets
}

output "dns_name" {
  value = aws_globalaccelerator_accelerator.main-accelerator.dns_name
}
