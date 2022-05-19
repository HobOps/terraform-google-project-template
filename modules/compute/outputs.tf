output "instance" {
  value = google_compute_instance.default
}

output "private_ip" {
  value = google_compute_instance.default.network_interface.0.network_ip
}

output "public_ip" {
  value = var.public_ip == true ? google_compute_address.default[0].address : ""
}

output "dns_record" {
  value = var.public_ip == true ? trimsuffix("${var.instance_name}.${data.google_dns_managed_zone.infra.0.dns_name}", ".") : ""
}
