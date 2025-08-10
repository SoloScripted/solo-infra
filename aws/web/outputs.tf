output "web_assets_bucket_id" {
  description = "The ID (name) of the S3 bucket for web assets."
  value       = aws_s3_bucket.web_assets.id
}

output "web_assets_bucket_arn" {
  description = "The ARN of the S3 bucket for web assets."
  value       = aws_s3_bucket.web_assets.arn
}

output "cloudfront_distribution_domain_names" {
  description = "A map of site names to their CloudFront distribution domain names."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.domain_name }
}

output "cloudfront_distribution_ids" {
  description = "A map of site names to their CloudFront distribution IDs."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.id }
}

output "cloudfront_distribution_arns" {
  description = "A map of site names to their CloudFront distribution ARNs."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.arn }
}

output "site_deploy_policy_arns" {
  description = "A map of site names to their deployment IAM policy ARNs."
  value       = { for k, v in aws_iam_policy.site_deploy : k => v.arn }
}
