# Google Artifact Registry
module "gar" {
  for_each      = var.gar.enabled == true ? toset(["main"]) : []
  depends_on    = [module.service_accounts]
  source        = "./modules/gar/"
  project_id    = var.project_id
  location      = var.region
  repository_id = var.gar.repository_id
  description   = var.gar.description
  format        = var.gar.format
}
