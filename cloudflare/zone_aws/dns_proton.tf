locals {
  protonmail_records = {
    txt_domain_verification = {
      name    = var.domain
      type    = "TXT"
      content = "protonmail-verification=339719c6af9a1a06c7c50b7144ed40ea2b695535"
    }
    mx_protonmail_10 = {
      name     = var.domain
      type     = "MX"
      content  = "mail.protonmail.ch"
      priority = 10
    }
    mx_protonmail_20 = {
      name     = var.domain
      type     = "MX"
      content  = "mailsec.protonmail.ch"
      priority = 20
    }
    txt_spf_protonmail = {
      name    = var.domain
      type    = "TXT"
      content = "v=spf1 include:_spf.protonmail.ch mx ~all"
    }
    cname_dkim_protonmail_1 = {
      name    = "protonmail._domainkey.${var.domain}"
      type    = "CNAME"
      content = "protonmail.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
    }
    cname_dkim_protonmail_2 = {
      name    = "protonmail2._domainkey.${var.domain}"
      type    = "CNAME"
      content = "protonmail2.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
    }
    cname_dkim_protonmail_3 = {
      name    = "protonmail3._domainkey.${var.domain}"
      type    = "CNAME"
      content = "protonmail3.domainkey.dqdipl5jzbor44yq3ag7o3lqv26oetrkkhc7y2acn6khiwy4e777q.domains.proton.ch"
    }
    txt_dmarc_protonmail = {
      name    = "_dmarc.${var.domain}"
      type    = "TXT"
      content = "v=DMARC1; p=quarantine;"
    }
  }
}

resource "cloudflare_dns_record" "protonmail_records" {
  for_each = local.protonmail_records

  name    = each.value.name
  type    = each.value.type
  ttl     = 1
  content = each.value.content
  zone_id = var.zone_id
  comment = var.comment

  priority = contains(["MX"], each.value.type) ? each.value.priority : null
}
