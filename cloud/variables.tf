# variables.tf
# Backblaze B2 Variables
variable "b2_access_key_id" {
  type        = string
  description = "B2 backend access key id"
}

variable "b2_secret_access_key" {
  type        = string
  description = "B2 backend secret access key"
}

# Cloudflare Variables
variable "cf_api_token" {
  type        = string
  description = "Cloudflare API Token for editing zone dns"
}

variable "cf_zone_id" {
  default = "6dfb9abb8a292cebb7a9be4944886e29"
}

variable "cf_domain" {
  default = "andywebservices.com"
}

variable "cf_comment" {
  default = "MANAGED BY gh-aws-infra/cloud DO NOT EDIT!!"
}

variable "cf_aws_chicago_ipv4" {
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

# Oracle Cloud Infrastructure Variable
variable "oci_tenancy_ocid" {
  sensitive = true
}

variable "oci_user_ocid" {
  sensitive = true
}

variable "oci_fingerprint" {
  sensitive = true
}

variable "oci_private_key" {
  sensitive = true
}

variable "oci_region" {
  sensitive = true
}

variable "oci_ssh_authorized_keys" {
  sensitive = true
}

# Tailscale
variable "tailnet" {
  type        = string
  description = "Name of tailnet, e.g. `some-name.ts.net`"
}

variable "tailscale_api_key" {
  type        = string
  description = "Tailscale API Key"
}
