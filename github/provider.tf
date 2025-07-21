terraform {
  required_version = ">= 1.12"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    region       = "eu-north-1"
    key          = "github/remote.state"
    use_lockfile = true
  }
}

provider "github" {
  owner = "SoloScripted"
}
