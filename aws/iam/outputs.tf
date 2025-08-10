output "github_oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arns" {
  description = "A map of repository roles to their corresponding IAM role ARNs."
  value = {
    for key, role in aws_iam_role.github_actions : key => role.arn
  }
}
