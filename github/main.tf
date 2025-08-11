data "github_user" "current" {
  username = ""
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    key    = "iam.state"
    region = "eu-north-1"
  }
}

data "terraform_remote_state" "web" {
  backend = "s3"
  config = {
    bucket = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    key    = "web.state"
    region = "eu-north-1"
  }
}

resource "github_repository" "this" {
  for_each = local.repositories

  allow_auto_merge            = each.value.visibility != "private"
  allow_merge_commit          = true
  allow_rebase_merge          = true
  allow_squash_merge          = true
  allow_update_branch         = true
  archived                    = false
  delete_branch_on_merge      = true
  description                 = each.value.description
  has_discussions             = false
  has_downloads               = try(each.value.downloads, false)
  has_issues                  = false
  has_projects                = false
  has_wiki                    = false
  is_template                 = false
  merge_commit_message        = "PR_BODY"
  merge_commit_title          = "PR_TITLE"
  name                        = each.key
  squash_merge_commit_message = "COMMIT_MESSAGES"
  squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
  topics                      = lookup(each.value, "topics", [])
  visibility                  = each.value.visibility
  vulnerability_alerts        = true
  web_commit_signoff_required = true
  auto_init                   = true

  dynamic "pages" {
    for_each = try(each.value.pages, null) != null ? [each.value.pages] : []

    content {
      build_type = pages.value.build_type
      cname      = try(pages.value.cname, null)

      source {
        branch = "main"
        path   = pages.value.build_type == "legacy" ? "/docs" : "/"
      }
    }
  }
}

resource "github_branch" "this" {
  for_each = local.repositories

  repository = github_repository.this[each.key].name
  branch     = "main"

  depends_on = [
    github_repository.this
  ]
}

resource "github_branch_protection" "this" {
  for_each = { for k, v in local.repositories : k => v if v.visibility != "private" }

  repository_id = github_repository.this[each.key].node_id

  allows_deletions                = false
  allows_force_pushes             = false
  enforce_admins                  = true
  lock_branch                     = false
  pattern                         = "main"
  require_conversation_resolution = true
  require_signed_commits          = true
  required_linear_history         = !try(each.value.allow_merge_commits_on_main, false)

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_last_push_approval      = true
    required_approving_review_count = 1
    restrict_dismissals             = true
    pull_request_bypassers = [
      "/ss-mkara"
    ]
  }

  dynamic "required_status_checks" {
    for_each = try(each.value.required_checks, null) != null ? [1] : []

    content {
      strict   = true
      contexts = each.value.required_checks
    }
  }

  depends_on = [
    github_repository.this
  ]
}

resource "github_repository_dependabot_security_updates" "this" {
  for_each = { for k, v in local.repositories : k => v if v.visibility != "private" && !try(v.disable_security_updates, false) }

  repository = github_repository.this[each.key].name
  enabled    = true
  depends_on = [
    github_repository.this
  ]
}

resource "github_repository_environment" "production" {
  for_each = { for k, v in local.repositories : k => v if try(v.protect_production, false) }

  repository          = github_repository.this[each.key].name
  environment         = "production"
  wait_timer          = 0
  can_admins_bypass   = true
  prevent_self_review = false
  reviewers {
    users = [
      data.github_user.current.id
    ]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  depends_on = [
    github_repository.this
  ]
}

resource "github_actions_secret" "this" {
  for_each = local.repository_secrets

  repository      = each.value.repo_key
  secret_name     = each.value.secret_name
  plaintext_value = each.value.value

  depends_on = [
    github_repository.this
  ]
}

resource "github_actions_variable" "this" {
  for_each = local.repository_variables

  repository    = each.value.repo_key
  variable_name = each.value.variable_name
  value         = each.value.value

  depends_on = [
    github_repository.this
  ]
}
