variable "dns" {
  type    = map(any)
  default = {}
}

module "dns" {
  for_each   = var.dns
  source     = "terraform-google-modules/cloud-dns/google"
  version    = "5.2.0"
  project_id = var.project_id
  type       = each.value["type"]
  name       = replace(each.key, ".", "-")
  domain     = "${each.key}."
  labels     = each.value["labels"]

  recordsets = each.value["recordsets"]
}
output "dns" {
  value     = module.gke
  sensitive = true
}