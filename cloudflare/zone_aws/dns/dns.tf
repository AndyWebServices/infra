resource "cloudflare_record" "A_root" {
  content = "204.14.39.222"
  name    = "andywebservices.com"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = var.zone_id
}

resource "cloudflare_record" "A_authentik" {
  content = "64.181.210.163"
  name    = "authentik"
  proxied = false
  ttl     = 60
  type    = "A"
  zone_id = var.zone_id
}

resource "cloudflare_record" "CNAME_lldap_to_authentik" {
  content = "authentik.andywebservices.com"
  name    = "lldap"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = var.zone_id
}
