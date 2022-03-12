# Get default service account
data "google_compute_default_service_account" "default" {
}

# Reserve public IP
resource "google_compute_address" "default" {
  count        = var.public_ip == true ? 1 : 0
  name         = var.instance_name
  address_type = "EXTERNAL"
  description  = "External IP"
  network_tier = var.public_ip_network_tier
  region       = var.region
  project      = var.project
}

# Create compute instance
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.instance_image
      size  = var.instance_disk_size
      type  = var.instance_disk_type
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  network_interface {
    subnetwork = var.subnetwork
    dynamic "access_config" {
      for_each = var.public_ip == true ? {
        access_config = {
          nat_ip       = google_compute_address.default[0].address
          network_tier = var.public_ip_network_tier
        }
      } : {}
      content {
        nat_ip       = access_config.value.nat_ip
        network_tier = access_config.value.network_tier
      }
    }
  }

  metadata = var.metadata

  labels = var.labels

  tags = var.instance_tags

  can_ip_forward = var.can_ip_forward

  service_account {
    //    email = data.google_compute_default_service_account.default.email
    //    email = data.google_compute_default_service_account.default.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  lifecycle {
    ignore_changes = [
      metadata["windows-keys"],
      boot_disk["initialize_params"],
      boot_disk["image"],
      boot_disk["labels"]
    ]
  }
}

# Create snapshot policy
resource "google_compute_resource_policy" "bootdisk_backup" {
  name   = "${var.instance_name}-bootdisk-backup"
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
    retention_policy {
      max_retention_days    = var.max_retention_days
      on_source_disk_delete = "APPLY_RETENTION_POLICY"
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "boot_disk_backup" {
  name = google_compute_resource_policy.bootdisk_backup.name
  disk = split("/disks/", google_compute_instance.default.boot_disk[0].source)[1]
  zone = var.zone
}

# Create recordset
data "google_dns_managed_zone" "infra" {
  count   = var.create_dns_record == true ? 1 : 0
  project = var.dns_project_id
  name    = var.dns_managed_zone
}

resource "google_dns_record_set" "A" {
  count   = var.create_dns_record == true ? 1 : 0
  name    = "${var.instance_name}.${data.google_dns_managed_zone.infra.0.dns_name}"
  project = var.dns_project_id
  type    = "A"
  ttl     = 60

  managed_zone = data.google_dns_managed_zone.infra.0.name

  rrdatas = [google_compute_instance.default.network_interface[0].network_ip]
}