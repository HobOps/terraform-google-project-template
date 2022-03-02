# https://github.com/terraform-google-modules/terraform-google-healthcare
module "healthcare_fhir_stores" {
  for_each = var.healthcare_fhir_stores
  source   = "terraform-google-modules/healthcare/google"
  version  = "2.2.0"

  project  = var.project_id
  name     = each.key
  location = lookup(each.value, "location", var.region)

  fhir_stores = lookup(each.value, "fhir_stores")
}