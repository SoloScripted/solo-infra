locals {
  reference_name = "SoloScripted"
  zones = {
    "soloscripted.com" = {
      comment = "Default public zone for SoloScripted."
      records = {
        "@" = [
          {
            type    = "MX"
            ttl     = 28800
            records = ["10 smtp.google.com"]
          },
          {
            type    = "TXT"
            ttl     = 28800
            records = ["google-site-verification=dvnw4fNM0xTv--ogzDMWrqKPQlBPBx7xMdGI8x1M2oY"]
          },
        ],
        "aws" = [
          {
            type    = "CNAME"
            ttl     = 28800
            records = ["051008159209.signin.aws.amazon.com."]
          }
        ]
      }
    }
  }

  dns_records_map = {
    for record in flatten([
      for zone_name, zone_details in local.zones : [
        for record_name, record_definitions in zone_details.records : [
          for record_def in record_definitions : {
            zone_key   = zone_name
            record_key = "${record_name}-${record_def.type}"
            name       = record_name == "@" ? zone_name : "${record_name}.${zone_name}"
            type       = record_def.type
            ttl        = record_def.ttl
            records    = record_def.records
          }
        ]
      ]
    ]) : "${record.zone_key}-${record.record_key}" => record
  }
}

resource "aws_route53_delegation_set" "this" {
  reference_name = local.reference_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_zone" "this" {
  for_each = local.zones

  name              = each.key
  comment           = each.value.comment
  delegation_set_id = aws_route53_delegation_set.this.id
}

resource "aws_route53_record" "this" {
  for_each = local.dns_records_map

  zone_id = aws_route53_zone.this[each.value.zone_key].zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records

  lifecycle {
    create_before_destroy = true
  }
}
