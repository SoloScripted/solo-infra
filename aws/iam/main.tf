data "terraform_remote_state" "web" {
  backend = "s3"
  config = {
    bucket = "storagestack-terraformstatebucket7379689d-ds1j1hn5qpbo"
    key    = "web.state"
    region = "eu-north-1"
  }
}
