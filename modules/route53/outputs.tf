output "app_dns" {
  description = "DNS name of the application"
  value       = aws_route53_record.app_dns.name
}

