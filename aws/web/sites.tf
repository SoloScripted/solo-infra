locals {
  sites = {
    "soloscripted" = {
      domains     = ["soloscripted.com", "www.soloscripted.com"]
      origin_path = "/www"
    }
    "sudokode" = {
      domains     = ["sudokode.soloscripted.com"]
      origin_path = "/sudokode"
    }
  }
}