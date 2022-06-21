# locals {
#   distinct_domain_names = distinct(
#     [for s in concat([var.domain], aws_acm_certificate.main.subject_alternative_names) : replace(s, "*.", "")]
#   )
#   # https://github.com/hashicorp/terraform/issues/26043
#   domain_validation_option = tolist(aws_acm_certificate.main.domain_validation_options)[0]
# }

# resource "cloudflare_zone" "default" {
#   zone = var.domain
# }

# # domain validation
# resource "cloudflare_record" "validation" {
#   count = length(local.distinct_domain_names)

#   zone_id = cloudflare_zone.default.id
#   name    = local.domain_validation_option.resource_record_name
#   type    = local.domain_validation_option.resource_record_type
#   # ACM DNS validation record returns the value with a trailing dot however the Cloudflare API trims it off.
#   # https://github.com/cloudflare/terraform-provider-cloudflare/issues/154
#   value = trimsuffix(local.domain_validation_option.resource_record_value, ".")
# }
