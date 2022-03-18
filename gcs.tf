variable "gcs_buckets" {
  type    = any
  default = {}
}

module "gcs_buckets" {
  for_each           = var.gcs_buckets
  source             = "terraform-google-modules/cloud-storage/google"
  version            = "v3.2.0"
  project_id         = lookup(each.value, "project_id", var.project_id)
  names              = lookup(each.value, "names", [])
  prefix             = lookup(each.value, "prefix", "")
  set_admin_roles    = lookup(each.value, "set_admin_roles", true)
  admins             = lookup(each.value, "admins", [])
  versioning         = lookup(each.value, "versioning", {})
  bucket_policy_only = lookup(each.value, "bucket_policy_only", {})
  bucket_admins      = lookup(each.value, "bucket_admins", {})
  bucket_viewers     = lookup(each.value, "bucket_viewers", {})
  force_destroy      = lookup(each.value, "force_destroy", {})
  labels             = lookup(each.value, "labels", {})
  location           = lookup(each.value, "location", "US")
  logging            = lookup(each.value, "logging", {})
  randomize_suffix   = lookup(each.value, "randomize_suffix", false)
}

output "gcs_buckets" {
  value = module.gcs_buckets
}