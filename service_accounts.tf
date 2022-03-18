variable "service_accounts" {
  type = any
  default = {}
}

module "service_accounts" {
  for_each      = var.service_accounts
  source        = "terraform-google-modules/service-accounts/google"
  version       = "4.1.1"
  project_id    = var.project_id
  prefix        = lookup(each.value, "prefix", "")
  names         = [each.key]
  project_roles = lookup(each.value, "project_roles", [])
  generate_keys = lookup(each.value, "generate_keys", false)
}

output "service_accounts" {
  value     = module.service_accounts
  sensitive = true
}