variable "instance_group" {
  type    = any
  default = {}
}

module "instance_group" {
  source         = "./modules/instance_group"
  instance_group = var.instance_group
}

output "instance_group" {
  value = module.instance_group
}
