resource "namecheap_domain_records" "azhg-me" {
  domain     = "azhg.me"
  mode       = "OVERWRITE" // Warning: this will remove all manually set records
  email_type = "MX"

  # Domain ownership verification
  record {
    hostname = "@"
    type     = "TXT"
    address  = "pm-verification=lvctrvcapjgrwgtxmxrntqyqrauvbt"
  }

  # MX Records
  record {
    hostname = "@"
    type     = "MX"
    address  = "mx1.alias.proton.me"
    mx_pref  = 10
  }
  record {
    hostname = "@"
    type     = "MX"
    address  = "mx2.alias.proton.me"
    mx_pref  = 20
  }

  # SPF
  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 include:alias.proton.me ~all"
  }

  # DKIM
  record {
    hostname = "dkim._domainkey"
    type     = "CNAME"
    address  = "dkim._domainkey.alias.proton.me"
  }
  record {
    hostname = "dkim02._domainkey"
    type     = "CNAME"
    address  = "dkim02._domainkey.alias.proton.me"
  }
  record {
    hostname = "dkim03._domainkey"
    type     = "CNAME"
    address  = "dkim03._domainkey.alias.proton.me"
  }

  # DMARC
  record {
    hostname = "_dmarc"
    type     = "TXT"
    address  = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"
  }
}
