# Container Registry
module "gcr" {
  for_each   = var.enable_gcr == true ? toset(["main"]) : []
  source     = "./modules/gcr/"
  project_id = var.project_id
}