output "vpc" {
  value = module.vpc
}

output "addresses" {
  value = module.addresses
}

output "cloud_router" {
  value = module.cloud_router
}

output "compute_instances" {
  value = module.compute_instances
}

output "gcr" {
  value     = module.gcr
  sensitive = true
}

output "cloud_sql_mysql" {
  value     = module.cloud_sql_mysql
  sensitive = true
}

output "cloud_sql_postgresql" {
  value     = module.cloud_sql_postgresql
  sensitive = true
}
