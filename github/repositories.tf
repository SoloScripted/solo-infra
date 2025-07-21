locals {
  repositories = {
    ".github" = {
      description              = "SoloScripted"
      visibility               = "public"
      disable_security_updates = true
    }

    aws-bootstrap = {
      description        = "TypeScript-based AWS CDK project for managing cloud infrastructure as code; designed for seamless Terraform collaboration."
      visibility         = "public"
      topics             = ["aws", "cdk", "terraform", "cloud", "infrastructure", "cloud-infrastructure"]
      protect_production = true
    }

    flutter-shared-components = {
      description = "Shared Flutter components and utilities for SoloScripted projects."
      visibility  = "public"
      topics      = ["flutter", "dart", "flutter-package", "components", "ui-kit"]
    }

    solo-infra = {
      description = "Core infrastructure for SoloScripted using Terraform. Provisions GitHub integrations and AWS environment."
      visibility  = "private"
    }

    ss-docs = {
      description = "Official documentation for SoloScripted — an AI-powered indie software and game studio."
      visibility  = "public"
      downloads   = true
      pages = {
        build_type = "legacy"
        cname      = "soloscripted.com"
      }
      disable_security_updates = true
    }

    sudokode = {
      description = "AI-driven Sudoku game built with Flutter & Dart for iOS, Android, and Web."
      visibility  = "public"
      pages = {
        build_type = "workflow"
      }
    }
  }
}