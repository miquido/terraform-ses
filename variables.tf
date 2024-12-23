variable "top_domain" {
  type = string
  description = "domain under which SES will operate"
}

variable "dmarc_mailto" {
  type = string
  description = "rua=mailto:"
}