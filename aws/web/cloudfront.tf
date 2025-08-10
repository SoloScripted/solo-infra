data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "web_assets" {
  name                              = "OAC-soloscripted-web-assets"
  description                       = "Origin Access Control for the web assets S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  for_each = local.sites

  origin {
    domain_name              = aws_s3_bucket.web_assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.web_assets.id
    origin_id                = "S3-soloscripted-web-assets"
    origin_path              = each.value.origin_path
  }

  aliases = each.value.domains

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"
  price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-soloscripted-web-assets"

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.soloscripted.certificate_arn
    ssl_support_method  = "sni-only"
  }
}