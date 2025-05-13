# Helpful Instructions

```
# Replace these with your own 1Password Secret References
export CLOUDFLARE_API_TOKEN=$(op read "op://Private/cjjzwd3qngerj6jzvu3g3y2wse/credential")
export CLOUDFLARE_EMAIL=$(op read "op://Private/cjjzwd3qngerj6jzvu3g3y2wse/username"
export CLOUDFLARE_ZONE_ID=6dfb9abb8a292cebb7a9be4944886e29

# Dumps the current Cloudflare state onto local. Uses OpenTofu on MacOS
cf-terraforming generate -e $CLOUDFLARE_EMAIL -t $CLOUDFLARE_API_TOKEN -z --resource-type cloudflare_record --provider-registry-hostname registry.opentofu.org --terraform-binary-path /opt/homebrew/bin/tofu > importing-example.tf

# Run all the commands produced by this cmd. Remember to replace 'terraform' in the cmd w/ 'tofu'
cf-terraforming import -e $CLOUDFLARE_EMAIL -t $CLOUDFLARE_API_TOKEN -z $CLOUDFLARE_ZONE_ID --resource-type cloudflare_record --provider-registry-hostname registry.opentofu.org --terraform-binary-path /opt/homebrew/bin/tofu

```
