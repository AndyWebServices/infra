terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

provider "cloudflare" {
  # token pulled from $CLOUDFLARE_API_TOKEN
}

variable "zone_id" {
  default = "6dfb9abb8a292cebb7a9be4944886e29"
}

variable "account_id" {
  default = "aad57bf06f66f299d32f1323117f8a19"
}

variable "domain" {
  default = "andywebservices.com"
}

