terraform {
  backend "s3" {
    access_key = var.b2_access_key_id
    secret_key = var.b2_secret_access_key

    bucket = "gh-aws-infra"
    key    = "cloud/terraform.state"
    region = "us-west-004"
    endpoint = "s3.us-west-004.backblazeb2.com"

    # necessary settings to make s3 backend work with b2
    skip_s3_checksum            = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    oci = {
      source  = "oracle/oci"
      version = "7.5.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.20.0"
    }
  }
}

# Cloudflare Provider Settings and Variables
provider "cloudflare" {
  api_token = var.cf_api_token
}

# Oracle Cloud Infra
provider "oci" {
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
  fingerprint  = var.oci_fingerprint
  private_key  = var.oci_private_key
  region       = var.oci_region
}

# Tailscale
provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailnet
}
