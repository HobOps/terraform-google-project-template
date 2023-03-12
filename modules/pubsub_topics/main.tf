resource "google_pubsub_topic" "default" {
  name    = var.topic
  project = var.project_id

}

resource "google_pubsub_subscription" "default" {
  name                       = "${var.topic}-sub"
  count                      = var.create_default_subscription ? 1 : 0
  topic                      = google_pubsub_topic.default.name
  project                    = var.project_id
  message_retention_duration = var.message_retention_duration
  retain_acked_messages      = var.retain_acked_messages
  ack_deadline_seconds       = var.ack_deadline_seconds
  enable_message_ordering    = var.enable_message_ordering
  expiration_policy {
    ttl = var.expiration_policy_ttl
  }
}