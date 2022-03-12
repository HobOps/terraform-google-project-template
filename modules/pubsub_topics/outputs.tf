output "topic" {
  value = google_pubsub_topic.default
}

output "subscription" {
  value = google_pubsub_subscription.default.*
}