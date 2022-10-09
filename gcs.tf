variable "gcs_buckets" {
  type    = any
  default = {}
}

module "gcs_buckets" {
  for_each         = var.gcs_buckets
  depends_on       = [module.service_accounts]
  source           = "terraform-google-modules/cloud-storage/google"
  version          = "v3.4.0"
  project_id       = lookup(each.value, "project_id", var.project_id)
  names            = [each.key]
  prefix           = lookup(each.value, "prefix", "")
  set_admin_roles  = lookup(each.value, "set_admin_roles", true)
  set_viewer_roles = lookup(each.value, "set_viewer_roles", true)
  storage_class    = lookup(each.value, "storage_class", "STANDARD")
  admins           = lookup(each.value, "admins", [])
  versioning = {
    "${each.key}" = lookup(each.value, "versioning", false)
  }
  bucket_policy_only = {
    "${each.key}" = lookup(each.value, "bucket_policy_only", true)
  }
  bucket_admins = {
    "${each.key}" = lookup(each.value, "bucket_admins", "")
  }
  bucket_viewers = {
    "${each.key}" = lookup(each.value, "bucket_viewers", "")
  }
  force_destroy = {
    "${each.key}" = lookup(each.value, "force_destroy", false)
  }
  labels = lookup(each.value, "labels", {})
  logging = {
    "${each.key}" = lookup(each.value, "logging", {})
  }
  bucket_lifecycle_rules = {
    "${each.key}" = lookup(each.value, "bucket_lifecycle_rules", [])
  }
  location         = lookup(each.value, "location", "US")
  randomize_suffix = lookup(each.value, "randomize_suffix", false)
}

output "gcs_buckets" {
  value = module.gcs_buckets
}