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

variable "b2_access_key_id" {
  type = string
  description = "B2 Access Key Id"
}
variable "b2_secret_access_key" {
  type = string
  description = "B2 Secret Access Key"
}