terraform {
  backend "s3" {
    # access_key pulled from $AWS_ACCESS_KEY_ID
    # secret_access_key pulled from $AWS_SECRET_ACCESS_KEY
    bucket   = "gh-aws-infra"
    key      = "tailscale/aws_tailnet/terraform.state"
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
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.20.0"
    }
  }
}

provider "tailscale" {
  # api_key set by $TAILSCALE_API_KEY
  # tailnet set by $TAILSCALE_TAILNET
}
