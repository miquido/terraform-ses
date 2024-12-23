module "ses" {
  source = "../../"

  dmarc_mailto = "devops@miquido.com"
  top_domain   = "example.com"
}
