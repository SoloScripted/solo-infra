resource "aws_acm_certificate" "soloscripted" {
  provider = aws.us-east-1

  domain_name               = "soloscripted.com"
  subject_alternative_names = ["*.soloscripted.com"]
  validation_method         = "DNS"

  tags = {
    Name = "soloscripted.com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "soloscripted" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.soloscripted.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}