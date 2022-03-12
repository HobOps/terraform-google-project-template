resource "google_pubsub_topic" "default" {
  name     = var.topic
  project  = var.project_id

}

resource "google_pubsub_subscription" "default" {
  name  = "${var.topic}-sub"
  count = var.create_default_subscription ? 1 : 0
  topic = google_pubsub_topic.default.name
  project  = var.project_id
  message_retention_duration = "604800s"
  retain_acked_messages      = false
  ack_deadline_seconds = 10
  expiration_policy {
    ttl = "2678400s"
  }
  enable_message_ordering    = false
}