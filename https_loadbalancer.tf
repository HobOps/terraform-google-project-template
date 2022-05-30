variable "https_loadbalancer" {
  type    = any
  default = {}
}

variable "managed_certificates" {
  type    = any
  default = {}
}

variable "url_map" {
  type    = any
  default = ""
}

module "https_loadbalancer" {
  for_each                        = var.https_loadbalancer
  source                          = "./modules/https_loadbalancer"
  name                            = each.key
  project                         = lookup(each.value, "project", var.project_id)
  firewall_networks               = lookup(each.value, "firewall_networks", [])
  create_url_map                  = lookup(each.value, "create_url_map", false)
  ssl                             = lookup(each.value, "ssl", true)
  use_ssl_certificates            = lookup(each.value, "use_ssl_certificates", false)
  random_certificate_suffix       = true
  managed_ssl_certificate_domains = lookup(each.value, "managed_ssl_certificate_domains", [])
  https_redirect                  = lookup(each.value, "https_redirect", true)
  create_address                  = lookup(each.value, "create_address", false)
  address                         = lookup(each.value, "address", "")
  backends                        = lookup(each.value, "backends", {})
  url_map                         = lookup(each.value, "url_map", "")
}

output "https_loadbalancer" {
  value = module.https_loadbalancer
}