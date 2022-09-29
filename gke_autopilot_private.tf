variable "gke_autopilot_private" {
  type    = map(any)
  default = {}
}

module "gke_autopilot_private" {
  for_each   = var.gke_autopilot_private
  depends_on = [module.vpc, module.service_accounts]
  source     = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version    = "23.0.0"

  add_cluster_firewall_rules           = lookup(each.value, "add_cluster_firewall_rules", false)
  add_master_webhook_firewall_rules    = lookup(each.value, "add_master_webhook_firewall_rules", false)
  add_shadow_firewall_rules            = lookup(each.value, "add_shadow_firewall_rules", false)
  authenticator_security_group         = lookup(each.value, "authenticator_security_group", null)
  cluster_ipv4_cidr                    = lookup(each.value, "cluster_ipv4_cidr", null)
  cluster_resource_labels              = lookup(each.value, "cluster_resource_labels", {})
  cluster_telemetry_type               = lookup(each.value, "cluster_telemetry_type", null)
  configure_ip_masq                    = lookup(each.value, "configure_ip_masq", null)
  create_service_account               = lookup(each.value, "create_service_account", true)
  database_encryption                  = lookup(each.value, "database_encryption", [])
  datapath_provider                    = lookup(each.value, "datapath_provider", "DATAPATH_PROVIDER_UNSPECIFIED")
  deploy_using_private_endpoint        = lookup(each.value, "deploy_using_private_endpoint", false)
  description                          = lookup(each.value, "description", "")
  disable_default_snat                 = lookup(each.value, "disable_default_snat", false)
  dns_cache                            = lookup(each.value, "dns_cache", true)
  enable_confidential_nodes            = lookup(each.value, "enable_confidential_nodes", false)
  enable_network_egress_export         = lookup(each.value, "enable_network_egress_export", false)
  enable_private_endpoint              = lookup(each.value, "enable_private_endpoint", false)
  enable_private_nodes                 = lookup(each.value, "enable_private_nodes", false)
  enable_resource_consumption_export   = lookup(each.value, "enable_resource_consumption_export", true)
  enable_tpu                           = lookup(each.value, "enable_tpu", false)
  enable_vertical_pod_autoscaling      = lookup(each.value, "enable_vertical_pod_autoscaling", false)
  firewall_inbound_ports               = lookup(each.value, "firewall_inbound_ports", [])
  firewall_priority                    = lookup(each.value, "firewall_priority", 1000)
  grant_registry_access                = lookup(each.value, "grant_registry_access", false)
  horizontal_pod_autoscaling           = lookup(each.value, "horizontal_pod_autoscaling", true)
  http_load_balancing                  = lookup(each.value, "http_load_balancing", true)
  identity_namespace                   = lookup(each.value, "identity_namespace", "enabled")
  ip_masq_link_local                   = lookup(each.value, "ip_masq_link_local", false)
  ip_masq_resync_interval              = lookup(each.value, "ip_masq_resync_interval", "60s")
  ip_range_pods                        = each.value["ip_range_pods"]
  ip_range_services                    = each.value["ip_range_services"]
  issue_client_certificate             = lookup(each.value, "issue_client_certificate", false)
  kubernetes_version                   = lookup(each.value, "kubernetes_version", "latest")
  logging_service                      = lookup(each.value, "logging_service", "logging.googleapis.com/kubernetes")
  maintenance_end_time                 = lookup(each.value, "maintenance_end_time", "")
  maintenance_exclusions               = lookup(each.value, "maintenance_exclusions", [])
  maintenance_recurrence               = lookup(each.value, "maintenance_recurrence", "")
  maintenance_start_time               = lookup(each.value, "maintenance_start_time", "05:00")
  master_authorized_networks           = lookup(each.value, "master_authorized_networks", [])
  master_global_access_enabled         = lookup(each.value, "master_global_access_enabled", true)
  master_ipv4_cidr_block               = lookup(each.value, "master_ipv4_cidr_block", "10.0.0.0/28")
  monitoring_enable_managed_prometheus = lookup(each.value, "monitoring_enable_managed_prometheus", false)
  monitoring_service                   = lookup(each.value, "monitoring_service", "monitoring.googleapis.com/kubernetes")
  name                                 = each.key
  network                              = each.value["network"]
  network_project_id                   = lookup(each.value, "network_project_id", "")
  non_masquerade_cidrs                 = lookup(each.value, "non_masquerade_cidrs", [])
  notification_config_topic            = lookup(each.value, "notification_config_topic", "")
  project_id                           = var.project_id
  region                               = each.value["region"]
  regional                             = lookup(each.value, "regional", true)
  registry_project_ids                 = lookup(each.value, "registry_project_ids", [])
  release_channel                      = lookup(each.value, "release_channel", null)
  resource_usage_export_dataset_id     = lookup(each.value, "resource_usage_export_dataset_id", "")
  service_account                      = lookup(each.value, "service_account", "")
  shadow_firewall_rules_priority       = lookup(each.value, "shadow_firewall_rules_priority", 999)
  skip_provisioners                    = lookup(each.value, "skip_provisioners", false)
  stub_domains                         = lookup(each.value, "stub_domains", {})
  subnetwork                           = each.value["subnetwork"]
  timeouts                             = lookup(each.value, "timeouts", {})
  upstream_nameservers                 = lookup(each.value, "upstream_nameservers", [])
  zones                                = each.value["zones"]
}

output "gke_autopilot_private" {
  value     = module.gke_autopilot_private
  sensitive = true
}