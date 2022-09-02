variable "gke" {
  type    = map(any)
  default = {}
}

module "gke" {
  for_each   = var.gke
  depends_on = [module.vpc, module.service_accounts]
  source     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version    = "23.0.0"

  project_id                      = var.project_id
  name                            = each.key
  region                          = each.value["region"]
  zones                           = each.value["zones"]
  regional                        = lookup(each.value, "regional", true)
  network                         = each.value["network"]
  subnetwork                      = each.value["subnetwork"]
  ip_range_pods                   = each.value["ip_range_pods"]
  ip_range_services               = each.value["ip_range_services"]
  kubernetes_version              = lookup(each.value, "kubernetes_version", "latest")
  default_max_pods_per_node       = lookup(each.value, "default_max_pods_per_node", 110)
  enable_shielded_nodes           = lookup(each.value, "enable_shielded_nodes", true)
  horizontal_pod_autoscaling      = lookup(each.value, "horizontal_pod_autoscaling", true)
  enable_vertical_pod_autoscaling = lookup(each.value, "enable_vertical_pod_autoscaling", false)
  http_load_balancing             = lookup(each.value, "http_load_balancing", true)
  network_policy                  = lookup(each.value, "network_policy", false)
  create_service_account          = lookup(each.value, "create_service_account", false)
  enable_private_endpoint         = lookup(each.value, "enable_private_endpoint", false)
  enable_private_nodes            = lookup(each.value, "enable_private_nodes", false)
  remove_default_node_pool        = lookup(each.value, "remove_default_node_pool", true)
  add_cluster_firewall_rules      = lookup(each.value, "add_cluster_firewall_rules", false)
  firewall_inbound_ports          = lookup(each.value, "firewall_inbound_ports", [])
  identity_namespace              = lookup(each.value, "identity_namespace", "${var.project_id}.svc.id.goog")
  maintenance_start_time          = lookup(each.value, "maintenance_start_time", "06:00")
  database_encryption             = lookup(each.value, "database_encryption", [])
  master_ipv4_cidr_block          = lookup(each.value, "master_ipv4_cidr_block", null)
  node_pools                      = each.value["node_pools"]
  node_pools_labels               = each.value["node_pools_labels"]
  node_pools_metadata             = each.value["node_pools_metadata"]
  node_pools_taints               = each.value["node_pools_taints"]
  node_pools_tags                 = each.value["node_pools_tags"]
  node_pools_oauth_scopes         = each.value["node_pools_oauth_scopes"]
  master_authorized_networks      = each.value["master_authorized_networks"]
}

output "gke" {
  value     = module.gke
  sensitive = true
}