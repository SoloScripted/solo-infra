locals {
    zone_id="a1bc4756ff2aa8449eb2efee9aed85ff"
  records = {
    "soloscripted.com" = {
      TXT = [{ content = "\"google-site-verification=dvnw4fNM0xTv--ogzDMWrqKPQlBPBx7xMdGI8x1M2oY\"" }]
      MX  = [{ priority = 10, content = "smtp.google.com" }]
      A   = [{ content = "185.199.108.153" },{ content = "185.199.109.153" },{ content = "185.199.110.153" },{ content = "185.199.111.153" }]
      AAAA  = [{ content = "2606:50c0:8000::153" },{ content = "2606:50c0:8001::153" },{ content = "2606:50c0:8002::153" },{ content = "2606:50c0:8003::153" }]
    },
    "aws.soloscripted.com" = {
        CNAME = [{ content = "051008159209.signin.aws.amazon.com" }]
    },
    "_github-pages-challenge-soloscripted.soloscripted.com" = {
        TXT = [{ content = "\"8cbda95e0448d0112ace257b247505\"" }]
    },
    "_github-pages-challenge-soloscripted.sudokode.soloscripted.com" = {
        TXT = [{ content = "\"9782ef89c5928a9cd3362605c1e9bd\"" }]
    },
    "_gh-soloscripted-o.soloscripted.com" = {
      TXT = [{ content = "\"ac404aabb8\"" }]
    }, 
    "_gh-soloscripted-o.sudokode.soloscripted.com" = {
      TXT = [{ content = "\"8e41c9c630\"" }]
    }, 
    "sudokode.soloscripted.com" = {
      CNAME = [{ content = "soloscripted.github.io" }]
    },
    "www.soloscripted.com" = {
      CNAME = [{ content = "soloscripted.github.io" }]
    }
  }


  dns_records_map = {
    for record in flatten([
      for name, types in local.records : [
        for type, record_list in types : [
          for record_data in record_list : {
            name     = name
            type     = type
            content    = record_data.content
            priority = try(record_data.priority, null)
          }
        ]
      ]
    ]) : "${record.type}-${record.name}-${record.content}" => record
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = local.dns_records_map

  zone_id  = local.zone_id
  name     = each.value.name
  type     = each.value.type
  content    = each.value.content
  priority = each.value.priority
  ttl      = 28800
  proxied  = false
}