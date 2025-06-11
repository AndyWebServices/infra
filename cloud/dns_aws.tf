# Configure ipv4, ipv6, and cname records here!!
locals {
  dns_entries = {
    k1-ingress = {
      ipv4 = var.cf_aws_chicago_ipv4
      cnames = ["", "actual", "ha", "homepage", "karakeep", "a1", "checkmk", "chat"]
    }
    auth = {
      ipv4 = var.authentik_ipv4
      cnames = ["authentik"]
    }
    overwatch = {
      ipv4 = var.overwatch_ipv4
      cnames = ["whoami.overwatch", "status", "uptime", "id", "lldap", "hub"]
    }
  }
}

locals {
  # DO NOT CONFIGURE THE BELOW!!
  cname_map = {
    # Flatten dns_entries map into a list of objects, then convert to map string -> object that we can for_each over
    for triple in flatten([
      for domain, data in local.dns_entries : [
        for cname in data.cnames : {
          key    = "${cname}-${domain}"
          domain = domain
          cname  = cname
        }
      ]
    ]) : triple.key => {
      domain = triple.domain
      cname  = triple.cname
    }
  }
}

# Create all A records
resource "cloudflare_dns_record" "a_records" {
  for_each = local.dns_entries

  name    = "${each.key}.${var.cf_domain}"
  content = each.value.ipv4
  proxied = true
  ttl     = 1
  zone_id = var.cf_zone_id
  type    = "A"
  comment = var.cf_comment
}

# Create all AAAA records
# resource "cloudflare_dns_record" "a_records" {
#   for_each = var.dns_entries
#
#   name    = "${each.key}.${var.domain}"
#   content = each.value.ipv6
#   proxied = true
#   ttl     = 1
#   zone_id = var.zone_id
#   type    = "AAAAA"
#   comment = var.comment
# }

# Create all CNAME records
resource "cloudflare_dns_record" "cname_records" {
  for_each = local.cname_map

  name    = "${each.value.cname != "" ? "${each.value.cname}." : ""}${var.cf_domain}"
  content = "${each.value.domain}.${var.cf_domain}"
  type    = "CNAME"
  ttl     = 1
  proxied = false # A names are proxied to hide IPs. CNAMEs point to proxied A records
  zone_id = var.cf_zone_id
  comment = var.cf_comment
}

# Create misc TXT record
resource "cloudflare_dns_record" "txt_kerberos" {
  name    = "_kerberos.${var.cf_domain}"
  type    = "TXT"
  ttl     = 1
  content = "ANDYWEBSERVICES.COM"
  zone_id = var.cf_zone_id
  comment = var.cf_comment
}
