# VPC
# https://github.com/terraform-google-modules/terraform-google-network
module "vpc" {
  for_each = var.vpc
  source   = "terraform-google-modules/network/google"
  version  = "5.0.0"

  project_id       = var.project_id
  network_name     = each.key
  description      = lookup(each.value, "description", "")
  routing_mode     = lookup(each.value, "routing_mode", "GLOBAL")
  subnets          = lookup(each.value, "subnets", [])
  secondary_ranges = lookup(each.value, "secondary_ranges", {})
  routes           = lookup(each.value, "routes", [])
  mtu              = lookup(each.value, "mtu", 0)
  shared_vpc_host  = lookup(each.value, "shared_vpc_host", false)

  auto_create_subnetworks                = lookup(each.value, "auto_create_subnetworks", false)
  delete_default_internet_gateway_routes = lookup(each.value, "delete_default_internet_gateway_routes", false)
}

# Addresses
# https://github.com/terraform-google-modules/terraform-google-address
module "addresses" {
  for_each     = var.addresses
  depends_on   = [module.vpc]
  source       = "terraform-google-modules/address/google"
  version      = "3.1.1"
  names        = [each.key]
  project_id   = var.project_id
  region       = lookup(each.value, "region", null)
  address_type = lookup(each.value, "address_type", "EXTERNAL")
  ip_version   = lookup(each.value, "ip_version", "IPV4")
  global       = lookup(each.value, "global", false)
  network_tier = lookup(each.value, "network_tier", "PREMIUM")
  addresses    = lookup(each.value, "addresses", [])
  subnetwork   = lookup(each.value, "subnetwork", null)
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

# VPC Serverless connector
module "serverless_connector" {
  for_each   = var.serverless_connector
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version    = "5.0.0"
  project_id = var.project_id
  vpc_connectors = [{
    name            = each.key
    region          = lookup(each.value, "region", var.region)
    network         = lookup(each.value, "network", null)
    ip_cidr_range   = lookup(each.value, "ip_cidr_range", null)
    subnet_name     = lookup(each.value, "subnet_name", null)
    host_project_id = lookup(each.value, "host_project_id", null)
    machine_type    = lookup(each.value, "machine_type", "e2-micro")
    min_instances   = lookup(each.value, "min_instances", 2)
    max_instances   = lookup(each.value, "max_instances", 3)
    max_throughput  = lookup(each.value, "max_throughput", 300)
  }]
}
