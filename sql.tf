locals {
  default_mysql_flags = [
    {
      name  = "sql_mode"
      value = "NO_ENGINE_SUBSTITUTION,NO_AUTO_CREATE_USER,ERROR_FOR_DIVISION_BY_ZERO"
    },
    {
      name  = "log_output"
      value = "FILE"
    },
    {
      name  = "slow_query_log"
      value = "on"
    },
    {
      name  = "long_query_time"
      value = "15"
    }
  ]
  default_postgresql_flags = [
    {
      name  = "log_min_duration_statement"
      value = "10000"
    }
  ]
}
# https://github.com/terraform-google-modules/terraform-google-sql-db
module "cloud_sql_mysql" {
  for_each             = var.cloud_sql_mysql
  depends_on           = [module.vpc, module.private-service-access]
  source = "github.com/inetshell/terraform-google-sql-db/google//modules/mysql?ref=fix-sensitive-values-isssue"
//  source               = "GoogleCloudPlatform/sql-db/google//modules/mysql"
//  version              = "9.0.0"
  name                 = each.key
  project_id           = var.project_id
  random_instance_name = lookup(each.value, "random_instance_name", true)
  database_version     = lookup(each.value, "database_version", "MYSQL_5_7")
  tier                 = lookup(each.value, "tier", "db-n1-standard-1")

  region            = lookup(each.value, "region", var.region)
  zone              = lookup(each.value, "zone", var.zone)
  availability_type = lookup(each.value, "availability_type", "ZONAL")

  ip_configuration = {
    authorized_networks = lookup(each.value, "authorized_networks", [])
    ipv4_enabled        = lookup(each.value, "ipv4_enabled", true)
    private_network     = lookup(each.value, "private_network", null)
    require_ssl         = lookup(each.value, "require_ssl", null)
    allocated_ip_range  = lookup(each.value, "allocated_ip_range", null)
  }

  user_name        = lookup(each.value, "user_name", "root")
  user_password    = lookup(each.value, "user_password", "")
  additional_users = nonsensitive(lookup(each.value, "additional_users", []))

  deletion_protection = lookup(each.value, "deletion_protection", true)

  disk_size       = lookup(each.value, "disk_size", 10)
  disk_type       = lookup(each.value, "disk_type", "PD_SSD")
  disk_autoresize = lookup(each.value, "disk_autoresize", true)

  database_flags = lookup(each.value, "database_flags", local.default_mysql_flags)

  maintenance_window_day          = 6
  maintenance_window_hour         = 7
  maintenance_window_update_track = "canary"

  backup_configuration = {
    retained_backups               = lookup(each.value, "retained_backups", 30)
    retention_unit                 = lookup(each.value, "retention_unit", "COUNT")
    binary_log_enabled             = lookup(each.value, "binary_log_enabled", true)
    enabled                        = lookup(each.value, "enabled", true)
    location                       = lookup(each.value, "location", var.region)
    point_in_time_recovery_enabled = lookup(each.value, "point_in_time_recovery_enabled", false)
    start_time                     = lookup(each.value, "start_time", "07:00")
    transaction_log_retention_days = lookup(each.value, "transaction_log_retention_days", 7)
  }
}

module "cloud_sql_postgresql" {
  for_each             = var.cloud_sql_postgresql
  depends_on           = [module.vpc, module.private-service-access]
  source               = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version              = "9.0.0"
  name                 = each.key
  project_id           = var.project_id
  random_instance_name = lookup(each.value, "random_instance_name", true)
  database_version     = lookup(each.value, "database_version", "POSTGRES_13")
  tier                 = lookup(each.value, "tier", "db-custom-1-3840")

  region            = lookup(each.value, "region", var.region)
  zone              = lookup(each.value, "zone", var.zone)
  availability_type = lookup(each.value, "availability_type", "ZONAL")

  ip_configuration = {
    authorized_networks = lookup(each.value, "authorized_networks", [])
    ipv4_enabled        = lookup(each.value, "ipv4_enabled", true)
    private_network     = lookup(each.value, "private_network", null)
    require_ssl         = lookup(each.value, "require_ssl", null)
    allocated_ip_range  = lookup(each.value, "allocated_ip_range", null)
  }

  user_name        = lookup(each.value, "user_name", "postgres")
  user_password    = lookup(each.value, "user_password", "")
  additional_users = nonsensitive(lookup(each.value, "additional_users", []))

  deletion_protection = lookup(each.value, "deletion_protection", true)

  disk_size       = lookup(each.value, "disk_size", 10)
  disk_type       = lookup(each.value, "disk_type", "PD_SSD")
  disk_autoresize = lookup(each.value, "disk_autoresize", true)

  database_flags = lookup(each.value, "database_flags", local.default_postgresql_flags)

  maintenance_window_day          = 6
  maintenance_window_hour         = 7
  maintenance_window_update_track = "canary"

  insights_config = {
    query_string_length     = lookup(each.value, "query_string_length", 1024)
    record_application_tags = lookup(each.value, "record_application_tags", false)
    record_client_address   = lookup(each.value, "record_client_address", false)
  }

  backup_configuration = {
    binary_log_enabled             = lookup(each.value, "binary_log_enabled", true)
    enabled                        = lookup(each.value, "enabled", true)
    point_in_time_recovery_enabled = lookup(each.value, "point_in_time_recovery_enabled", false)
    start_time                     = lookup(each.value, "start_time", "07:00")
    transaction_log_retention_days = lookup(each.value, "transaction_log_retention_days", 7)
    retained_backups               = lookup(each.value, "retained_backups", 30)
    retention_unit                 = lookup(each.value, "retention_unit", "COUNT")
    location                       = lookup(each.value, "location", var.region)
  }
}

