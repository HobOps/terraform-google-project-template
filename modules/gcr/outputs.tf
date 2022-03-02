# Outputs
output "gcr_push_user" {
  value = google_service_account.gcr_push_user.email
}

output "gcr_push_key" {
  value     = google_service_account_key.gcr_push_user_key.private_key
  sensitive = true
}

output "gcr_pull_user" {
  value = google_service_account.gcr_pull_user.email
}

output "gcr_pull_key" {
  value     = google_service_account_key.gcr_pull_user_key.private_key
  sensitive = true
}