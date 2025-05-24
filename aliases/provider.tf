terraform {
  backend "s3" {
    # access_key pulled from $AWS_ACCESS_KEY_ID
    # secret_access_key pulled from $AWS_SECRET_ACCESS_KEY
    bucket   = "gh-aws-infra"
    key      = "namecheap/azhgme/terraform.state"
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
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}

# user_name pulled from $NAMECHEAP_USER_NAME
# api_user pulled from $NAMECHEAP_API_USER
# api_key pulled from $NAMECHEAP_API_KEY
provider "namecheap" {

}
