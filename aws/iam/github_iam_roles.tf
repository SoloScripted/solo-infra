locals {
  repository_roles = {
    "aws-bootstrap" = {
      "pr" = {
        description   = "IAM role for GitHub Actions PRs in the SoloScripted/aws-bootstrap repository."
        ref_condition = "repo:SoloScripted/aws-bootstrap:pull_request"
        policies = [
          "arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess",
          "arn:aws:iam::aws:policy/ReadOnlyAccess"
        ]
      }
      "production" = {
        description   = "IAM role for GitHub Actions deployments to the production environment of SoloScripted/aws-bootstrap."
        ref_condition = "repo:SoloScripted/aws-bootstrap:environment:production"
        policies = [
          "arn:aws:iam::aws:policy/AdministratorAccess"
        ]
      }
    }
    "ss-docs" = {
      "production" = {
        description   = "IAM role for deploying the ss-docs site to the production environment."
        ref_condition = "repo:SoloScripted/ss-docs:environment:production"
        policies      = [data.terraform_remote_state.web.outputs.site_deploy_policy_arns["soloscripted"]]
      }
    }
    "sudokode" = {
      "production" = {
        description   = "IAM role for deploying the sudokode site to the production environment."
        ref_condition = "repo:SoloScripted/sudokode:environment:production"
        policies      = [data.terraform_remote_state.web.outputs.site_deploy_policy_arns["sudokode"]]
      }
    }
  }

  roles_map = {
    for role in flatten([
      for repo_name, contexts in local.repository_roles : [
        for context_name, context_details in contexts : {
          role_key      = "${repo_name}-${context_name}"
          role_name     = "GitHubActionsRole-${repo_name}-${context_name}"
          description   = context_details.description
          ref_condition = context_details.ref_condition
          policies      = context_details.policies
        }
      ]
    ]) : role.role_key => role
  }

  policy_attachments_map = {
    for attachment in flatten([
      for role_key, role_details in local.roles_map : [
        for policy_arn in role_details.policies : {
          role_key   = role_key
          policy_arn = policy_arn
        }
      ]
    ]) : "${attachment.role_key}-${element(split("/", attachment.policy_arn), 1)}" => attachment
  }
}

resource "aws_iam_role" "github_actions" {
  for_each = local.roles_map

  name = each.value.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = each.value.ref_condition
          }
        }
      }
    ]
  })

  description = each.value.description
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  for_each = local.policy_attachments_map

  role       = aws_iam_role.github_actions[each.value.role_key].name
  policy_arn = each.value.policy_arn
}