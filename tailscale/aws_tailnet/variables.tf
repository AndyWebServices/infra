# variables.tf
variable "admin_user" {
  type        = string
  description = "Name of an admin user"
}

variable "member_user" {
  type        = string
  description = "Name of a member user"
}

variable "tailnet" {
  type        = string
  description = "Name of tailnet, e.g. `some-name.ts.net`"
}

variable "tailscale_api_key" {
  type = string
  description = "Tailscale API Key"
}
