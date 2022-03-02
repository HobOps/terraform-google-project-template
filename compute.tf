# Compute instances
module "compute_instances" {
  for_each = var.compute_instances
  source   = "./modules/compute/"

  # Instance properties
  project        = var.project_id
  instance_name  = each.key
  machine_type   = lookup(each.value, "machine_type", "e2-medium")
  region         = lookup(each.value, "region", var.region)
  zone           = lookup(each.value, "zone", var.zone)
  instance_image = lookup(each.value, "instance_image")
  metadata       = lookup(each.value, "metadata", {})
  labels         = lookup(each.value, "labels", {})

  # Network
  subnetwork        = lookup(each.value, "subnetwork")
  instance_tags     = lookup(each.value, "instance_tags", [])
  public_ip         = lookup(each.value, "public_ip", false)
  create_dns_record = lookup(each.value, "create_dns_record", false)
  dns_project_id    = lookup(each.value, "dns_project_id", var.project_id)
  dns_managed_zone  = lookup(each.value, "dns_managed_zone")

  # Storage and backups
  instance_disk_size = lookup(each.value, "instance_disk_size", 64)
  instance_disk_type = lookup(each.value, "instance_disk_type", "pd-ssd")
  max_retention_days = lookup(each.value, "max_retention_days", 15)
}