# variables.tf
variable "b2_access_key_id" {
  type = string
  description = "B2 backend access key id"
}

variable "b2_secret_access_key" {
  type = string
  description = "B2 backend secret access key"
}

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare API Token for editing zone dns"
}

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