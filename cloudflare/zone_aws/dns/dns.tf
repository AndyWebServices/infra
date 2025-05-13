resource "cloudflare_record" "terraform_managed_resource_bc5aab57f19ced78fbcfe4811e35ec21" {
  content = "204.14.39.222"
  name    = "andywebservices.com"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_5750dbf3eea7ddba71d1f1135af97d81" {
  content = "64.181.210.163"
  name    = "authentik"
  proxied = false
  ttl     = 60
  type    = "A"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_3773276d7e18e85374bd10579dfe7d09" {
  content = "authentik.andywebservices.com"
  name    = "lldap"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_597809e8a09e444af8808496688e39a4" {
  content = "pikvm.tail7b68d.ts.net"
  name    = "pikvm"
  proxied = false
  ttl     = 60
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_7e49b84fbb1e97dc1b8ae5bc88438922" {
  content = "protonmail2.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
  name    = "protonmail2._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_c3ac46f3d0b205ed844c0646f451f69c" {
  content = "protonmail3.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
  name    = "protonmail3._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_2b801404e40361b9ae2badd619843b4f" {
  content = "protonmail.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
  name    = "protonmail._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_14e5b1da0ecba590bcb775d3fda09dd5" {
  content = "andywebservices.github.io"
  name    = "status"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_2e043356e549cb7fba89b2c20fd3b684" {
  content = "overwatch.andywebservices.com"
  name    = "uptime"
  proxied = false
  ttl     = 60
  type    = "CNAME"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_0d35edb50cfa1221e84044f42c65a51d" {
  content  = "mailsec.protonmail.ch"
  name     = "andywebservices.com"
  priority = 20
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_535e6075b6259e8366db9003cd347c47" {
  content  = "mail.protonmail.ch"
  name     = "andywebservices.com"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  zone_id  = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_9acc4f0c4368b2bc77dbc4b53eced74d" {
  content = "v=spf1 include:_spf.protonmail.ch mx ~all"
  name    = "andywebservices.com"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_5721a200909af0b88d0a3176a9b9935c" {
  content = "protonmail-verification=339719c6af9a1a06c7c50b7144ed40ea2b695535"
  name    = "andywebservices.com"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_187638dbc29ab5a0513329df2c737558" {
  content = "v=DMARC1; p=quarantine;"
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_b04ea404207825f29f83c527165d1a6f" {
  comment = "Domain verification for Github Pages"
  content = "66c55fd4785f3b2c4d9c08981cba3c"
  name    = "_github-pages-challenge-andywebservices.status"
  proxied = false
  ttl     = 1
  type    = "TXT"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

resource "cloudflare_record" "terraform_managed_resource_2cd005fbe5c994c92cc2ccfdb53959e1" {
  content = "ANDYWEBSERVICES.COM"
  name    = "_kerberos"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  zone_id = "6dfb9abb8a292cebb7a9be4944886e29"
}

