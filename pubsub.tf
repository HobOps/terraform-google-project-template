variable "pubsub_topics" {
  type = any
  default = {}
}

module "pubsub_topics" {
  for_each   = var.pubsub_topics
  source     = "./modules/pubsub_topics/"
  project_id = var.project_id
  topic = each.key
  create_default_subscription = lookup(each.value, "create_default_subscription", true )
}

output "pubsub_topics" {
  value = module.pubsub_topics
}