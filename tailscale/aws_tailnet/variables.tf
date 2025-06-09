# variables.tf
variable "b2_access_key_id" {
  type        = string
  description = "B2 Access Key Id"
}
variable "b2_secret_access_key" {
  type        = string
  description = "B2 Secret Access Key"
}

variable "tailnet" {
  type        = string
  description = "Name of tailnet, e.g. `some-name.ts.net`"
}

variable "tailscale_api_key" {
  type        = string
  description = "Tailscale API Key"
}
