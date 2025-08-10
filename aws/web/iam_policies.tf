resource "aws_iam_policy" "site_deploy" {
  for_each = local.sites

  name        = "GitHubActions-Site-Deploy-${each.key}"
  description = "Allows deploying assets for the ${each.key} site and invalidating its CloudFront distribution."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Sync"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.web_assets.arn,
          "${aws_s3_bucket.web_assets.arn}/*"
        ]
      },
      {
        Sid      = "AllowCloudFrontInvalidation"
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = aws_cloudfront_distribution.this[each.key].arn
      }
    ]
  })
}