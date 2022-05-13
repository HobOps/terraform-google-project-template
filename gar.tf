# Google Artifact Registry
module "gar" {
  for_each   = var.enable_gar == true ? toset(["main"]) : []
  depends_on = [module.service_accounts]
  source     = "./modules/gar/"
  project_id = var.project_id
  location = var.location
  description = var.description
}
