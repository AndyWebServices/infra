# variables.tf
variable "tailscale_client_id" {
  type        = string
  description = "Tailscale OAuth Client Id"
}

variable "tailscale_client_secret" {
  type        = string
  description = "Tailscale OAuth Client Secret"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
}

variable "longhorn_backup_cifs_username" {
  type = string
  description = "Longhorn backup CIFS username"
}

variable "longhorn_backup_cifs_password" {
  type = string
  description = "Longhorn backup CIFS password"
}

