# Enable GCR API
resource "google_project_service" "containerregistry" {
  service = "containerregistry.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Creates GCR
resource "google_container_registry" "registry" {
  project  = var.project_id
  location = var.location
}

# Creates service account for pushing
resource "google_service_account" "gcr_push_user" {
  account_id   = "gcr-push-user"
  display_name = "service account for GCR with push permissions"
}

resource "google_service_account_key" "gcr_push_user_key" {
  service_account_id = google_service_account.gcr_push_user.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_storage_bucket_iam_member" "gcr_push" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${google_service_account.gcr_push_user.email}"
}

# Creates service account for pulling
resource "google_service_account" "gcr_pull_user" {
  account_id   = "gcr-pull-user"
  display_name = "service account for GCR with pull permissions"
}

resource "google_service_account_key" "gcr_pull_user_key" {
  service_account_id = google_service_account.gcr_pull_user.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_storage_bucket_iam_member" "gcr_pull" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gcr_pull_user.email}"
}

