# Container Registry
module "gcr" {
  for_each   = var.enable_gcr == true ? toset(["main"]) : []
  depends_on = [module.service_accounts]
  source     = "./modules/gcr/"
  project_id = var.project_id
}