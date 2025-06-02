# variables.tf
variable "aws_chicago_ipv4" {
  type        = string
  description = "ipv4 address of chicago HQ server"
}

variable "overlord_ipv6" {
  type        = string
  description = "ipv6 address of server overlord"
  default     = ""
}

variable "authentik_ipv4" {
  type        = string
  description = "ipv4 address of server authentik"
}

variable "authentik_ipv6" {
  type        = string
  description = "ipv6 address of server authentik"
  default     = ""
}

variable "overwatch_ipv4" {
  type        = string
  description = "ipv4 address of server overwatch"
}

variable "overwatch_ipv6" {
  type        = string
  description = "ipv6 address of server overwatch"
  default     = ""
}