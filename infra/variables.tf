variable "location" {
  type    = string
  default = "uaenorth"
}

variable "project" {
  type    = string
  default = "ghaplat"
}

variable "app_service_sku" {
  type    = string
  default = "B1"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}
