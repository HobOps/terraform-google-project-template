# Enable GAR API
resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Create GAR registry
resource "google_artifact_registry_repository" "gar" {
  provider = google-beta
  depends_on = [google_project_service.artifactregistry]

  location = var.location
  repository_id = var.repository_id
  description = var.description
  format = var.format
}

# writer
resource "google_service_account" "gar_push_user" {
  account_id   = "gar-push-user"
  display_name = "service account for GAR with push permissions"
}

resource "google_service_account_key" "gar_push_user_key" {
  provider = google-beta

  service_account_id = google_service_account.gar_push_user.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_artifact_registry_repository_iam_member" "gar_push" {
  provider = google-beta

  location = google_artifact_registry_repository.gar.location
  repository = google_artifact_registry_repository.gar.name
  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.gar_push_user.email}"
}


# READER
resource "google_service_account" "gar_pull_user" {
  account_id   = "gar-pull-user"
  display_name = "service account for GAR with pull permissions"
}

resource "google_service_account_key" "gar_pull_user_key" {
  service_account_id = google_service_account.gar_pull_user.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_artifact_registry_repository_iam_member" "gar_pull" {
  provider = google-beta

  location = google_artifact_registry_repository.gar.location
  repository = google_artifact_registry_repository.gar.name
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gar_pull_user.email}"
}