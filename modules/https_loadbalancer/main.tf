/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  backends = {
    for key, value in var.backends : key => {
      description                     = lookup(value, "description", null)
      protocol                        = lookup(value, "protocol", "HTTP")
      port                            = lookup(value, "port", 80)
      port_name                       = lookup(value, "port_name", "http")
      timeout_sec                     = lookup(value, "timeout_sec", 100)
      connection_draining_timeout_sec = lookup(value, "connection_draining_timeout_sec", 60)
      enable_cdn                      = lookup(value, "enable_cdn", false)
      security_policy                 = lookup(value, "security_policy", null)
      session_affinity                = lookup(value, "session_affinity", null)
      affinity_cookie_ttl_sec         = lookup(value, "affinity_cookie_ttl_sec", null)
      custom_request_headers          = lookup(value, "custom_request_headers", null)
      custom_response_headers         = lookup(value, "custom_response_headers", null)
      health_check = {
        check_interval_sec  = lookup(value, "health_check_check_interval_sec", 30)
        timeout_sec         = lookup(value, "health_check_timeout_sec", 10)
        healthy_threshold   = lookup(value, "health_check_healthy_threshold", 1)
        unhealthy_threshold = lookup(value, "health_check_unhealthy_threshold", 3)
        request_path        = lookup(value, "health_check_request_path", "/")
        port                = lookup(value, "health_check_port", 80)
        host                = lookup(value, "health_check_host", null)
        logging             = lookup(value, "health_check_logging", null)
      }
      log_config = {
        enable      = lookup(value, "health_check_enable", true)
        sample_rate = lookup(value, "health_check_sample_rate", 1.0)
      }
      iap_config = {
        enable               = lookup(value, "iap_config_enable", false)
        oauth2_client_id     = lookup(value, "iap_config_oauth2_client_id", "")
        oauth2_client_secret = lookup(value, "iap_config_oauth2_client_secret", "")
      }
      groups = [
        for groups_value in value["groups"] : {
          group                        = lookup(groups_value, "group")
          balancing_mode               = lookup(groups_value, "balancing_mode", "RATE")
          capacity_scaler              = lookup(groups_value, "capacity_scaler", 1)
          description                  = lookup(groups_value, "description", null)
          max_connections              = lookup(groups_value, "max_connections", null)
          max_connections_per_instance = lookup(groups_value, "max_connections_per_instance", null)
          max_connections_per_endpoint = lookup(groups_value, "max_connections_per_endpoint", null)
          max_rate                     = lookup(groups_value, "max_rate", 100)
          max_rate_per_instance        = lookup(groups_value, "max_rate_per_instance", null)
          max_rate_per_endpoint        = lookup(groups_value, "max_rate_per_endpoint", null)
          max_utilization              = lookup(groups_value, "max_utilization", null)
        }
      ]

    }
  }

  address      = var.create_address ? join("", google_compute_global_address.default.*.address) : var.address
  ipv6_address = var.create_ipv6_address ? join("", google_compute_global_address.default_ipv6.*.address) : var.ipv6_address

//  url_map             = var.create_url_map ? join("", google_compute_url_map.default.*.self_link) : var.url_map #REMOVE
  create_http_forward = var.http_forward || var.https_redirect

  health_checked_backends = { for backend_index, backend_value in local.backends : backend_index => backend_value if backend_value["health_check"] != null }
}

### IPv4 block ###
resource "google_compute_global_forwarding_rule" "http" {
  project    = var.project
  count      = local.create_http_forward ? 1 : 0
  name       = var.name
  target     = google_compute_target_http_proxy.default[0].self_link
  ip_address = local.address
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "https" {
  project    = var.project
  count      = var.ssl ? 1 : 0
  name       = "${var.name}-https"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = local.address
  port_range = "443"
}

resource "google_compute_global_address" "default" {
  count      = var.create_address ? 1 : 0
  project    = var.project
  name       = "${var.name}-address"
  ip_version = "IPV4"
}
### IPv4 block ###

### IPv6 block ###
resource "google_compute_global_forwarding_rule" "http_ipv6" {
  project    = var.project
  count      = (var.enable_ipv6 && local.create_http_forward) ? 1 : 0
  name       = "${var.name}-ipv6-http"
  target     = google_compute_target_http_proxy.default[0].self_link
  ip_address = local.ipv6_address
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "https_ipv6" {
  project    = var.project
  count      = (var.enable_ipv6 && var.ssl) ? 1 : 0
  name       = "${var.name}-ipv6-https"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = local.ipv6_address
  port_range = "443"
}

resource "google_compute_global_address" "default_ipv6" {
  count      = (var.enable_ipv6 && var.create_ipv6_address) ? 1 : 0
  project    = var.project
  name       = "${var.name}-ipv6-address"
  ip_version = "IPV6"
}
### IPv6 block ###

# HTTP proxy when http forwarding is true
resource "google_compute_target_http_proxy" "default" {
  project = var.project
  count   = local.create_http_forward ? 1 : 0
  name    = "${var.name}-http-proxy"
  url_map = var.https_redirect == false ? var.url_map : join("", google_compute_url_map.https_redirect.*.self_link)
//  url_map = var.https_redirect == false ? local.url_map : join("", google_compute_url_map.https_redirect.*.self_link) #REMOVE
}

# HTTPS proxy when ssl is true
resource "google_compute_target_https_proxy" "default" {
  project = var.project
  count   = var.ssl ? 1 : 0
  name    = "${var.name}-https-proxy"
  url_map = var.url_map
//  url_map = local.url_map #REMOVE

  ssl_certificates = compact(concat(var.ssl_certificates, google_compute_ssl_certificate.default.*.self_link, google_compute_managed_ssl_certificate.default.*.self_link, ), )
  ssl_policy       = var.ssl_policy
  quic_override    = var.quic ? "ENABLE" : null
}

resource "google_compute_ssl_certificate" "default" {
  project     = var.project
  count       = var.ssl && length(var.managed_ssl_certificate_domains) == 0 && !var.use_ssl_certificates ? 1 : 0
  name_prefix = "${var.name}-certificate-"
  private_key = var.private_key
  certificate = var.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "certificate" {
  count       = var.random_certificate_suffix == true ? 1 : 0
  byte_length = 4
  prefix      = "${var.name}-cert-"

  keepers = {
    domains = join(",", var.managed_ssl_certificate_domains)
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta
  project  = var.project
  count    = var.ssl && length(var.managed_ssl_certificate_domains) > 0 && !var.use_ssl_certificates ? 1 : 0
  name     = var.random_certificate_suffix == true ? random_id.certificate[0].hex : "${var.name}-cert"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = var.managed_ssl_certificate_domains
  }
}

resource "google_compute_url_map" "default" {
  project         = var.project
  count           = var.create_url_map ? 1 : 0
  name            = var.name
  default_service = var.create_bucket ? google_compute_backend_bucket.static-content.0.self_link : google_compute_backend_service.default[keys(local.backends)[0]].self_link
}

resource "google_compute_url_map" "https_redirect" {
  project = var.project
  count   = var.https_redirect ? 1 : 0
  name    = "${var.name}-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_backend_service" "default" {
  provider = google-beta
  for_each = local.backends

  project = var.project
  name    = "${var.name}-backend-${each.key}"

  port_name = each.value.port_name
  protocol  = each.value.protocol

  timeout_sec                     = lookup(each.value, "timeout_sec", null)
  description                     = lookup(each.value, "description", null)
  connection_draining_timeout_sec = lookup(each.value, "connection_draining_timeout_sec", null)
  enable_cdn                      = lookup(each.value, "enable_cdn", false)
  custom_request_headers          = lookup(each.value, "custom_request_headers", [])
  custom_response_headers         = lookup(each.value, "custom_response_headers", [])
  health_checks                   = lookup(each.value, "health_check", null) == null ? null : [google_compute_health_check.default[each.key].self_link]
  session_affinity                = lookup(each.value, "session_affinity", null)
  affinity_cookie_ttl_sec         = lookup(each.value, "affinity_cookie_ttl_sec", null)

  # To achieve a null backend security_policy, set each.value.security_policy to "" (empty string), otherwise, it fallsback to var.security_policy.
  security_policy = lookup(each.value, "security_policy") == "" ? null : (lookup(each.value, "security_policy") == null ? var.security_policy : each.value.security_policy)

  dynamic "backend" {
    for_each = toset(each.value["groups"])
    content {
      description = lookup(backend.value, "description", null)
      group       = lookup(backend.value, "group")

      balancing_mode               = lookup(backend.value, "balancing_mode")
      capacity_scaler              = lookup(backend.value, "capacity_scaler")
      max_connections              = lookup(backend.value, "max_connections")
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance")
      max_connections_per_endpoint = lookup(backend.value, "max_connections_per_endpoint")
      max_rate                     = lookup(backend.value, "max_rate")
      max_rate_per_instance        = lookup(backend.value, "max_rate_per_instance")
      max_rate_per_endpoint        = lookup(backend.value, "max_rate_per_endpoint")
      max_utilization              = lookup(backend.value, "max_utilization")
    }
  }

  dynamic "log_config" {
    for_each = lookup(lookup(each.value, "log_config", {}), "enable", true) ? [1] : []
    content {
      enable      = lookup(lookup(each.value, "log_config", {}), "enable", true)
      sample_rate = lookup(lookup(each.value, "log_config", {}), "sample_rate", "1.0")
    }
  }

  dynamic "iap" {
    for_each = lookup(lookup(each.value, "iap_config", {}), "enable", false) ? [1] : []
    content {
      oauth2_client_id     = lookup(lookup(each.value, "iap_config", {}), "oauth2_client_id", "")
      oauth2_client_secret = lookup(lookup(each.value, "iap_config", {}), "oauth2_client_secret", "")
    }
  }

  depends_on = [
    google_compute_health_check.default
  ]

}

resource "google_compute_health_check" "default" {
  provider = google-beta
  for_each = local.health_checked_backends
  project  = var.project
  name     = "${var.name}-hc-${each.key}"

  check_interval_sec  = lookup(each.value["health_check"], "check_interval_sec", 5)
  timeout_sec         = lookup(each.value["health_check"], "timeout_sec", 5)
  healthy_threshold   = lookup(each.value["health_check"], "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value["health_check"], "unhealthy_threshold", 2)

  log_config {
    enable = lookup(each.value["health_check"], "logging", false)
  }

  dynamic "http_health_check" {
    for_each = each.value["protocol"] == "HTTP" ? [
      {
        host         = lookup(each.value["health_check"], "host", null)
        request_path = lookup(each.value["health_check"], "request_path", null)
        port         = lookup(each.value["health_check"], "port", null)
      }
    ] : []

    content {
      host         = lookup(http_health_check.value, "host", null)
      request_path = lookup(http_health_check.value, "request_path", null)
      port         = lookup(http_health_check.value, "port", null)
    }
  }

  dynamic "https_health_check" {
    for_each = each.value["protocol"] == "HTTPS" ? [
      {
        host         = lookup(each.value["health_check"], "host", null)
        request_path = lookup(each.value["health_check"], "request_path", null)
        port         = lookup(each.value["health_check"], "port", null)
      }
    ] : []

    content {
      host         = lookup(https_health_check.value, "host", null)
      request_path = lookup(https_health_check.value, "request_path", null)
      port         = lookup(https_health_check.value, "port", null)
    }
  }

  dynamic "http2_health_check" {
    for_each = each.value["protocol"] == "HTTP2" ? [
      {
        host         = lookup(each.value["health_check"], "host", null)
        request_path = lookup(each.value["health_check"], "request_path", null)
        port         = lookup(each.value["health_check"], "port", null)
      }
    ] : []

    content {
      host         = lookup(http2_health_check.value, "host", null)
      request_path = lookup(http2_health_check.value, "request_path", null)
      port         = lookup(http2_health_check.value, "port", null)
    }
  }
}

resource "google_compute_firewall" "default-hc" {
  count   = length(var.firewall_networks)
  project = length(var.firewall_networks) == 1 && var.firewall_projects[0] == "default" ? var.project : var.firewall_projects[count.index]
  name    = "${var.name}-hc-${count.index}"
  network = var.firewall_networks[count.index]
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  target_tags             = length(var.target_tags) > 0 ? var.target_tags : null
  target_service_accounts = length(var.target_service_accounts) > 0 ? var.target_service_accounts : null

  dynamic "allow" {
    for_each = local.health_checked_backends
    content {
      protocol = "tcp"
      ports    = [allow.value["health_check"].port]
    }
  }
}

resource "random_id" "static-content-bucket" {
  count       = var.create_bucket ? 1 : 0
  prefix      = "static-content-${var.name}-"
  byte_length = 4
}

resource "google_compute_backend_bucket" "static-content" {
  count       = var.create_bucket ? 1 : 0
  name        = random_id.static-content-bucket.0.hex
  description = "Contains static resources for example app"
  bucket_name = google_storage_bucket.static-content.0.name
  enable_cdn  = false
}

resource "google_storage_bucket" "static-content" {
  count    = var.create_bucket ? 1 : 0
  name     = random_id.static-content-bucket.0.hex
  location = "US"

  website {
    main_page_suffix = "maintenance.html"
    not_found_page   = "maintenance.html"
  }
  // delete bucket and contents on destroy.
  force_destroy = true
}

// Note that the path in the bucket matches the paths in the url map path rule above.
resource "google_storage_bucket_object" "maintenance_page" {
  count         = var.create_bucket ? 1 : 0
  name          = "maintenance.html"
  content       = file("${path.module}/default_files/maintenance.html")
  content_type  = "text/html"
  bucket        = google_storage_bucket.static-content.0.name
  cache_control = "public, max-age=3600"
}

// Make object public readable.
resource "google_storage_object_acl" "maintenance_page_acl" {
  count          = var.create_bucket ? 1 : 0
  bucket         = google_storage_bucket.static-content.0.name
  object         = google_storage_bucket_object.maintenance_page.0.name
  predefined_acl = "publicRead"
}
