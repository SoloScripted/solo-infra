output "name_servers" {
  description = "The public name servers"
  value       = aws_route53_delegation_set.this.name_servers
}

output "zones" {
  description = "A map of the created Route 53 zones with their details."
  value = {
    for zone in aws_route53_zone.this : zone.name => zone.zone_id
  }
}
