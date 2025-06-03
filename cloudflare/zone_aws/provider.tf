terraform {
  backend "s3" {
    aws_access_key_id = var.b2_access_key_id
    aws_secret_access_key = var.b2_secret_access_key

    bucket   = "gh-aws-infra"
    key      = "cloudlfare/zone_aws/terraform.state"
    region   = "us-west-004"
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
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
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

variable "comment" {
  default = "MANAGED BY gh-aws-infra/cloudflare/zone_aws DO NOT EDIT!!"
}