variable "pubsub_topics" {
  type = any
  default = {}
}

module "pubsub_topics" {
  for_each   = var.pubsub_topics
  source     = "./modules/pubsub_topics/"
  project_id = var.project_id
}

output "pubsub_topics" {
  value = module.pubsub_topics
}