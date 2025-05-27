# variables.tf
variable "admin_user" {
  type        = string
  description = "Name of an admin user"
}

variable "member_user" {
  type        = string
  description = "Name of a member user"
}
