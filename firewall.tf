locals {
  default_firewall_rules = [
    {
      name                    = "allow-ssh"
      description             = "Allow SSH"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["ssh"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-kubernetes-ports"
      description             = "Allow Kubernetes ports"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["10.0.0.0/8"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["kubernetes"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["6443"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-nginx-ingress"
      description             = "Allow NGINX ingress"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["nginx-ingress"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["8443"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-webserver"
      description             = "Allow webserver"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["webserver"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-ping"
      description             = "Allow ping"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["ping"]
      target_service_accounts = null
      allow = [{
        protocol = "icmp"
        ports    = null
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}

# Firewall
module "default_firewall_rules" {
  for_each     = var.create_default_firewall_rules ? var.vpc : {}
  depends_on   = [module.vpc, module.service_accounts]
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "5.0.0"
  project_id   = var.project_id
  network_name = each.key
  rules        = local.default_firewall_rules
}

module "firewall_rules" {
  for_each     = var.vpc
  depends_on   = [module.vpc, module.service_accounts]
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "5.0.0"
  project_id   = var.project_id
  network_name = each.key
  rules        = lookup(each.value, "firewall_rules", [])
}