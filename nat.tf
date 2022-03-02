# Cloud NAT
# https://github.com/terraform-google-modules/terraform-google-cloud-router
module "cloud_router" {
  for_each   = var.cloud_nat_routers
  depends_on = [module.addresses]
  source     = "terraform-google-modules/cloud-router/google"
  version    = "1.3.0"
  project    = var.project_id
  name       = each.key
  network    = lookup(each.value, "network")
  region     = lookup(each.value, "region", var.region)

  nats = [{
    name                               = lookup(each.value, "cloud_nat_name")
    source_subnetwork_ip_ranges_to_nat = lookup(each.value, "source_subnetwork_ip_ranges_to_nat", "ALL_SUBNETWORKS_ALL_IP_RANGES")
    nat_ips                            = lookup(each.value, "nat_ips")

    udp_idle_timeout_sec             = lookup(each.value, "udp_idle_timeout_sec", 30)
    icmp_idle_timeout_sec            = lookup(each.value, "icmp_idle_timeout_sec", 30)
    tcp_established_idle_timeout_sec = lookup(each.value, "tcp_established_idle_timeout_sec", 1200)
    tcp_transitory_idle_timeout_sec  = lookup(each.value, "tcp_transitory_idle_timeout_sec", 30)
    log_config = {
      filter = lookup(each.value, "log_config_filter", "ALL")
    }
  }]
}
