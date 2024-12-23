data "aws_region" "current_ses" {}
data "aws_route53_zone" "domain" {
  name = var.top_domain
}

resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.top_domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "_amazonses.${var.top_domain}"
  type    = "TXT"
  ttl     = "1800"
  records = [aws_ses_domain_identity.ses_domain.verification_token]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = aws_ses_domain_identity.ses_domain.domain
}

resource "aws_ses_domain_mail_from" "ses-system" {
  domain           = var.top_domain
  mail_from_domain = "mail.${var.top_domain}"
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count = 3

  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[count.index]}._domainkey.${var.top_domain}"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses-system-dmarc" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "_dmarc.${var.top_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [
    "v=DMARC1;p=reject;rua=mailto:${var.dmarc_mailto}"
  ]
}

resource "aws_route53_record" "ses-system-mail-from-spf" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.top_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "ses-system-mail-from-mx" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "mail.${var.top_domain}"
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current_ses.id}.amazonses.com"]
}

resource "aws_route53_record" "ses-system-mail-from-spf-subdomain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "mail.${var.top_domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
