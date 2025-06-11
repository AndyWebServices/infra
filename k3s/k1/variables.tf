# variables.tf
variable "b2_access_key_id" {
  type        = string
  description = "B2 backend access key id"
}

variable "b2_secret_access_key" {
  type        = string
  description = "B2 backend secret access key"
}

variable "tailscale_client_id" {
  type        = string
  description = "Tailscale OAuth Client Id"
}

variable "tailscale_client_secret" {
  type        = string
  description = "Tailscale OAuth Client Secret"
}

variable "tailscale_tailnet" {
  type        = string
  description = "Name of tailnet, e.g. `some-name.ts.net`"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
}

variable "longhorn_backup_cifs_username" {
  type        = string
  description = "Longhorn backup CIFS username"
}

variable "longhorn_backup_cifs_password" {
  type        = string
  description = "Longhorn backup CIFS password"
}

variable "nextauth_secret" {
  type        = string
  description = "NextAuth Secret"
}

variable "meili_master_key" {
  type        = string
  description = "Meili Master Key"
}

variable "next_public_secret" {
  type        = string
  description = "Next Public Secret"
}

variable "openwebui_oauth_client_id" {
  type    = string
  default = "OpenWebUI OAuth Client ID"
}

variable "openwebui_oauth_client_secret" {
  type    = string
  default = "OpenWebUI OAuth Client Secret"
}
