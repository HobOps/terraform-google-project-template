variable "bigquery" {
  type    = any
  default = {}
}

locals {
  default_bigquery_access = [
    {
      "role" : "roles/bigquery.dataOwner",
      "special_group" : "projectOwners"
    }
  ]
}

module "bigquery" {
  for_each   = var.bigquery
  depends_on = [module.service_accounts]
  source     = "terraform-google-modules/bigquery/google"
  version    = "5.4.0"

  dataset_id      = lookup(each.value, "dataset_id", each.key)
  dataset_name    = lookup(each.value, "dataset_name", each.key)
  description     = lookup(each.value, "description", "")
  dataset_labels  = lookup(each.value, "dataset_labels", {})
  project_id      = lookup(each.value, "project_id", var.project_id)
  location        = lookup(each.value, "location", "US")
  tables          = lookup(each.value, "tables", [])
  views           = lookup(each.value, "views", [])
  external_tables = lookup(each.value, "external_tables", [])
  encryption_key  = lookup(each.value, "encryption_key", null)
  routines        = lookup(each.value, "routines", [])

  default_table_expiration_ms = lookup(each.value, "default_table_expiration_ms", 3600000)
  delete_contents_on_destroy  = lookup(each.value, "delete_contents_on_destroy", false)
  deletion_protection         = lookup(each.value, "deletion_protection", true)
  materialized_views          = lookup(each.value, "materialized_views", [])

  access = concat(local.default_bigquery_access, lookup(each.value, "access", []))
}

output "bigquery" {
  value = module.bigquery
}
