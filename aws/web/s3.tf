resource "aws_s3_bucket" "web_assets" {
  bucket = "soloscripted-web-assets"
}

resource "aws_s3_bucket_versioning" "web_assets" {
  bucket = aws_s3_bucket.web_assets.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "web_assets" {
  bucket = aws_s3_bucket.web_assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "web_assets" {
  bucket = aws_s3_bucket.web_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_assets" {
  bucket = aws_s3_bucket.web_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "web_assets" {
  bucket = aws_s3_bucket.web_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceSecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.web_assets.arn,
          "${aws_s3_bucket.web_assets.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowCloudFront"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_assets.arn}/*"
        Condition = {
          ArnLike = {
            "AWS:SourceArn" = [for dist in aws_cloudfront_distribution.this : dist.arn]
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.web_assets]
}
