variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "vpc" {
  type = any
}

variable "addresses" {
  type = any
}

variable "cloud_nat_routers" {
  type = any
}

variable "serverless_connector" {
  type = any
  default = {}
}

variable "compute_instances" {
  type = any
}

variable "vpc_peering" {
  type    = any
  default = {}
}

variable "private_service_access" {
  type    = any
  default = {}
}

variable "cloud_sql_mysql" {
  type    = any
  default = {}
}

variable "cloud_sql_postgresql" {
  type    = any
  default = {}
}

variable "enable_gcr" {
  type    = bool
  default = false
}

variable "healthcare_fhir_stores" {
  type    = any
  default = {}
}

variable "https_loadbalancer" {
  type    = any
  default = {}
}

variable "managed_certificates" {
  type    = any
  default = {}
}

variable "url_map" {
  type    = any
  default = {}
}
