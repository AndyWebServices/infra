resource "namecheap_domain_records" "awsllc-me" {
  domain     = "awsllc.me"
  mode       = "OVERWRITE" // Warning: this will remove all manually set records
  email_type = "MX"

  # Domain ownership verification
  record {
    hostname = "@"
    type     = "TXT"
    address  = "sl-verification=ikyocsuphvrdcevdnrtmgzscamsmum"
  }

  # MX Records
  record {
    hostname = "@"
    type     = "MX"
    address  = "mx1.simplelogin.co."
    mx_pref  = 10
  }
  record {
    hostname = "@"
    type     = "MX"
    address  = "mx2.simplelogin.co."
    mx_pref  = 20
  }

  # SPF
  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 include:simplelogin.co ~all"
  }

  # DKIM
  record {
    hostname = "dkim._domainkey"
    type     = "CNAME"
    address  = "dkim._domainkey.simplelogin.co"
  }
  record {
    hostname = "dkim02._domainkey"
    type     = "CNAME"
    address  = "dkim02._domainkey.simplelogin.co"
  }
  record {
    hostname = "dkim03._domainkey"
    type     = "CNAME"
    address  = "dkim03._domainkey.simplelogin.co"
  }

  # DMARC
  record {
    hostname = "_dmarc"
    type     = "TXT"
    address  = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"
  }
}
