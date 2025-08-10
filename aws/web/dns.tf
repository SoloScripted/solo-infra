locals {
  domain_to_distribution_map = {
    for item in flatten([
      for site_key, site_details in local.sites : [
        for domain in site_details.domains : {
          domain_name                 = domain
          distribution_domain_name    = aws_cloudfront_distribution.this[site_key].domain_name
          distribution_hosted_zone_id = aws_cloudfront_distribution.this[site_key].hosted_zone_id
        }
      ]
    ]) : item.domain_name => item
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    key    = "dns.state"
    region = "eu-north-1"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.soloscripted.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.terraform_remote_state.dns.outputs.zones["soloscripted.com"]
}

resource "aws_route53_record" "cloudfront_aliases" {
  for_each = local.domain_to_distribution_map

  zone_id = data.terraform_remote_state.dns.outputs.zones["soloscripted.com"]
  name    = each.key
  type    = "A"

  alias {
    name                   = each.value.distribution_domain_name
    zone_id                = each.value.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_aliases_ipv6" {
  for_each = local.domain_to_distribution_map

  zone_id = data.terraform_remote_state.dns.outputs.zones["soloscripted.com"]
  name    = each.key
  type    = "AAAA"

  alias {
    name                   = each.value.distribution_domain_name
    zone_id                = each.value.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

moved {
  from = aws_iam_policy.web_assets_deploy
  to   = aws_iam_policy.site_deploy["soloscripted"]
}

moved {
  to   = aws_cloudfront_distribution.this["soloscripted"]
  from = aws_cloudfront_distribution.web_assets
}
