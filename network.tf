# VPC
# https://github.com/terraform-google-modules/terraform-google-network
module "vpc" {
  for_each = var.vpc
  source   = "terraform-google-modules/network/google"
  version  = "5.0.0"

  project_id       = var.project_id
  network_name     = each.key
  routing_mode     = lookup(each.value, "routing_mode", "GLOBAL")
  subnets          = lookup(each.value, "subnets", [])
  secondary_ranges = lookup(each.value, "secondary_ranges", {})
  routes           = lookup(each.value, "routes", [])
}

# Addresses
# https://github.com/terraform-google-modules/terraform-google-address
module "addresses" {
  for_each     = var.addresses
  source       = "terraform-google-modules/address/google"
  version      = "3.1.1"
  names        = [each.key]
  project_id   = var.project_id
  region       = lookup(each.value, "region", null)
  address_type = lookup(each.value, "address_type", "EXTERNAL")
  ip_version   = lookup(each.value, "ip_version", "IPV4")
  global       = lookup(each.value, "global", false)
  network_tier = lookup(each.value, "network_tier", "PREMIUM")
}

# Private access
# https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/examples/mysql-private
module "private-service-access" {
  for_each      = var.private_service_access
  depends_on    = [module.vpc]
  source        = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version       = "9.0.0"
  project_id    = var.project_id
  vpc_network   = each.key
  ip_version    = lookup(each.value, "ip_version", "IPV4")
  address       = lookup(each.value, "address")
  prefix_length = lookup(each.value, "prefix_length")
}