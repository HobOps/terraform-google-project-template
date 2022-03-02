# VPC Peering
module "vpc_peering" {
  for_each          = var.vpc_peering
  module_depends_on = [module.vpc]
  source            = "terraform-google-modules/network/google//modules/network-peering"
  version           = "5.0.0"

  prefix                                    = var.project_id
  local_network                             = module.vpc[each.key].network_id
  peer_network                              = each.value["peer_network"]
  export_local_custom_routes                = lookup(each.value, "export_local_custom_routes", false)
  export_peer_custom_routes                 = lookup(each.value, "export_peer_custom_routes", false)
  export_local_subnet_routes_with_public_ip = lookup(each.value, "export_local_subnet_routes_with_public_ip", false)
  export_peer_subnet_routes_with_public_ip  = lookup(each.value, "export_peer_subnet_routes_with_public_ip", true)
}