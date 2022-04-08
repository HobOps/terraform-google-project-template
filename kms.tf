variable "kms" {
  type    = any
  default = {}
}

module "kms" {
  for_each   = var.kms
  depends_on = [module.service_accounts]
  source     = "terraform-google-modules/kms/google"
  version    = "2.1.0"

  project_id           = var.project_id
  keyring              = each.key
  location             = lookup(each.value, "location", "global")
  prevent_destroy      = lookup(each.value, "prevent_destroy", true)
  keys                 = lookup(each.value, "keys", [])
  labels               = lookup(each.value, "labels", {})
  set_decrypters_for   = lookup(each.value, "set_decrypters_for", [])
  set_encrypters_for   = lookup(each.value, "set_encrypters_for", [])
  set_owners_for       = lookup(each.value, "set_owners_for", [])
  decrypters           = lookup(each.value, "decrypters", [])
  encrypters           = lookup(each.value, "encrypters", [])
  owners               = lookup(each.value, "owners", [])
  key_algorithm        = lookup(each.value, "key_algorithm", "GOOGLE_SYMMETRIC_ENCRYPTION")
  key_protection_level = lookup(each.value, "key_protection_level", "SOFTWARE")
  key_rotation_period  = lookup(each.value, "key_rotation_period", "100000s")
}

output "kms" {
  value = module.kms
}