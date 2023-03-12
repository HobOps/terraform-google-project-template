variable "project_id" {
  type = string
}

variable "location" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "format" {
  type    = string
  default = "DOCKER"
}