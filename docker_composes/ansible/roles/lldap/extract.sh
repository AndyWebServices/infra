#!/bin/bash

# Path to your acme.json
ACME_JSON="/home/ubuntu/docker/composes/traefik-docker/certs/letsencrypt-acme.json"

# Create output directory
OUT_DIR="./home/ubuntu/docker/composes/lldap-docker/certs/"
mkdir -p "$OUT_DIR"

# Extract domain list
jq -r '.letsencrypt.Certificates[] | .domain.main' "$ACME_JSON" | while read -r domain; do
  echo "Extracting cert for $domain"

  cert=$(jq -r ".letsencrypt.Certificates[] | select(.domain.main==\"$domain\") | .certificate" "$ACME_JSON" | base64 -d)
  key=$(jq -r ".letsencrypt.Certificates[] | select(.domain.main==\"$domain\") | .key" "$ACME_JSON" | base64 -d)

  echo "$cert" > "$OUT_DIR/$domain-fullchain.pem"
  echo "$key" > "$OUT_DIR/$domain-privkey.pem"

  echo "Saved: $OUT_DIR/$domain-fullchain.pem and privkey.pem"
done
