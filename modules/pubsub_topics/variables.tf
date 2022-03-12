variable "topic" {
  type = string
}

variable "project_id" {
  type = string
}

variable "create_default_subscription" {
  type = bool
  default = true
}

variable "message_retention_duration" {
  type = string
  default = "604800s"
}

variable "retain_acked_messages" {
  type = bool
  default = false
}

variable "ack_deadline_seconds" {
  type = number
  default = 10
}

variable "enable_message_ordering" {
  type = bool
  default = false
}

variable "expiration_policy_ttl" {
  type = string
  default = "2678400s"
}