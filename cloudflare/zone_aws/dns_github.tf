resource "cloudflare_dns_record" "txt_domain_verification_github_pages" {
  name    = "_github-pages-challenge-andywebservices.status.${var.domain}"
  type    = "TXT"
  ttl     = 1
  content = "66c55fd4785f3b2c4d9c08981cba3c"
  zone_id = var.zone_id
  comment = var.comment
}

resource "cloudflare_dns_record" "aws_docs_cname" {
  name    = "docs.andywebservices.com"
  type    = "CNAME"
  ttl     = 1
  content = "andywebservices.github.io"
  zone_id = var.zone_id
  comment = var.comment
}
