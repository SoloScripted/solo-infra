locals {
  repositories = {
    ".github" = {
      description              = "SoloScripted"
      visibility               = "public"
      topics                   = ["github", "community", "organization-files"]
      disable_security_updates = true
    }

    aws-bootstrap = {
      description        = "TypeScript-based AWS CDK project for managing cloud infrastructure as code; designed for seamless Terraform collaboration."
      visibility         = "public"
      topics             = ["aws", "cdk", "terraform", "cloud", "infrastructure", "cloud-infrastructure"]
      protect_production = true
      required_checks    = ["Lint and Format Check", "cdk-diff"]
      secrets = {
        AWS_VIEW_ONLY_ROLE_ARN = data.terraform_remote_state.iam.outputs.github_actions_role_arns["aws-bootstrap-pr"]
        AWS_ADMIN_ROLE_ARN     = data.terraform_remote_state.iam.outputs.github_actions_role_arns["aws-bootstrap-production"]
      }
      variables = {
        AWS_REGION = "eu-north-1"
      }
    }

    flutter-shared-components = {
      description     = "Shared Flutter components and utilities for SoloScripted projects."
      visibility      = "public"
      topics          = ["flutter", "dart", "flutter-package", "components", "ui-kit"]
      required_checks = ["Run Linter"]
    }

    solo-infra = {
      description = "Core infrastructure for SoloScripted using Terraform. Provisions GitHub integrations and AWS environment."
      visibility  = "public"
      topics      = ["terraform", "aws", "infrastructure-as-code", "github"]
    }

    ss-docs = {
      description        = "Official documentation for SoloScripted — an AI-powered indie software and game studio."
      visibility         = "public"
      downloads          = true
      protect_production = true
      topics             = ["documentation", "soloscripted"]
      required_checks    = ["Build Site"]
      secrets = {
        AWS_ADMIN_ROLE_ARN = data.terraform_remote_state.iam.outputs.github_actions_role_arns["ss-docs-production"]
      }
      variables = {
        AWS_REGION                     = "eu-north-1"
        AWS_S3_SITE_BUCKET_NAME        = data.terraform_remote_state.web.outputs.web_assets_bucket_id
        AWS_CLOUDFRONT_DISTRIBUTION_ID = data.terraform_remote_state.web.outputs.cloudfront_distribution_ids["soloscripted"]
      }
    }

    sudokode = {
      description        = "AI-driven Sudoku game built with Flutter & Dart for iOS, Android, and Web."
      visibility         = "public"
      protect_production = true
      topics             = ["flutter", "dart", "sudoku", "game", "mobile", "web"]
      required_checks    = ["build"]
      secrets = {
        AWS_ADMIN_ROLE_ARN = data.terraform_remote_state.iam.outputs.github_actions_role_arns["sudokode-production"]
      }
      variables = {
        AWS_REGION                     = "eu-north-1"
        AWS_S3_SITE_BUCKET_NAME        = data.terraform_remote_state.web.outputs.web_assets_bucket_id
        AWS_CLOUDFRONT_DISTRIBUTION_ID = data.terraform_remote_state.web.outputs.cloudfront_distribution_ids["sudokode"]
      }
    }
  }

  repository_secrets = {
    for secret in flatten([
      for repo_name, repo_details in local.repositories : [
        for secret_name, secret_value in try(repo_details.secrets, {}) : {
          repo_key    = repo_name
          secret_name = secret_name
          value       = secret_value
        }
      ]
    ]) : "${secret.repo_key}-${secret.secret_name}" => secret
  }

  repository_variables = {
    for variable in flatten([
      for repo_name, repo_details in local.repositories : [
        for variable_name, variable_value in try(repo_details.variables, {}) : {
          repo_key      = repo_name
          variable_name = variable_name
          value         = variable_value
        }
      ]
    ]) : "${variable.repo_key}-${variable.variable_name}" => variable
  }
}