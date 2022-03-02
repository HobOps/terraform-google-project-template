resource "google_compute_instance_group" "default" {
  for_each    = var.instance_group
  name        = each.key
  description = lookup(each.value, "description", "")
  instances   = lookup(each.value, "instances", [])
  zone        = lookup(each.value, "zone")

  dynamic "named_port" {
    for_each = lookup(each.value, "named_port", [])
    content {
      name = named_port.value["name"]
      port = named_port.value["port"]
    }
  }
}