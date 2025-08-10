terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0"
    }
  }

  backend "s3" {
    bucket       = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    region       = "eu-north-1"
    key          = "dns.state"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Stack       = "DNS"
      Environment = "Production"
      Project     = "SoloScripted"
      ManagedBy   = "Terraform"
    }
  }
}