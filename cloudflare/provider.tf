terraform {
  required_version = ">= 1.12"

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.7.1"
    }
  }

  backend "s3" {
    bucket       = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    region       = "eu-north-1"
    key          = "cloudflare/remote.state"
    use_lockfile = true
  }
}

