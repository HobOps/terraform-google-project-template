variable "instance_name" {}

variable "machine_type" {}

variable "region" {}

variable "zone" {}

variable "project" {}

variable "instance_image" {}

variable "instance_tags" {
  type = list(any)
}

variable "subnetwork" {}

variable "instance_disk_size" {
  default = "32"
}

variable "instance_disk_type" {
  default = "pd-ssd"
}

variable "labels" {
  type    = any
  default = {}
}
variable "metadata" {
  type    = map(string)
  default = {}
}

variable "max_retention_days" {
  default = 7
}

variable "public_ip" {
  type    = bool
  default = true
}

variable "public_ip_network_tier" {
  type    = string
  default = "PREMIUM"
}

variable "create_dns_record" {
  type    = bool
  default = false
}

variable "dns_project_id" {
  type    = string
  default = ""
}

variable "dns_managed_zone" {
  type    = string
  default = ""
}

variable "can_ip_forward" {
  type    = bool
  default = false
}