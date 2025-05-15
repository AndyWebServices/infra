resource "cloudflare_record" "TXT_domain_verification_protonmail" {
  content = "protonmail-verification=339719c6af9a1a06c7c50b7144ed40ea2b695535"
  name    = "andywebservices.com"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "MX_protonmail_10" {
  content  = "mail.protonmail.ch"
  name     = "andywebservices.com"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = var.zone_id
}

resource "cloudflare_record" "MX_protonmail_20" {
  content  = "mailsec.protonmail.ch"
  name     = "andywebservices.com"
  priority = 20
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = var.zone_id
}

resource "cloudflare_record" "TXT_spf_protonmail" {
  content = "v=spf1 include:_spf.protonmail.ch mx ~all"
  name    = "andywebservices.com"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "CNAME_dkim_protonmail_1" {
  content = "protonmail.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
  name    = "protonmail._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = var.zone_id
}

resource "cloudflare_record" "CNAME_dkim_protonmail_2" {
  content = "protonmail2.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
  name    = "protonmail2._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = var.zone_id
}

resource "cloudflare_record" "CNAME_dkim_protonmail_3" {
  content = "protonmail3.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
  name    = "protonmail3._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = var.zone_id
}

resource "cloudflare_record" "TXT_dmarc_protonmail" {
  content = "v=DMARC1; p=quarantine;"
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "TXT_domain_verification_github_pages" {
  comment = "Domain verification for Github Pages"
  content = "66c55fd4785f3b2c4d9c08981cba3c"
  name    = "_github-pages-challenge-andywebservices.status"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = var.zone_id
}

resource "cloudflare_record" "terraform_managed_resource_2cd005fbe5c994c92cc2ccfdb53959e1" {
  content = "ANDYWEBSERVICES.COM"
  name    = "_kerberos"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  zone_id = var.zone_id
}
