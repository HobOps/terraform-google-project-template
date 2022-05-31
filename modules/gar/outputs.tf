output "gar_push_user" {
  value = google_service_account.gar_push_user.email
}

output "gar_push_user_key" {
  value     = google_service_account_key.gar_push_user_key.private_key
  sensitive = true
}

output "gar_pull_user" {
  value = google_service_account.gar_pull_user.email
}

output "gar_pull_user_key" {
  value     = google_service_account_key.gar_pull_user_key.private_key
  sensitive = true
}