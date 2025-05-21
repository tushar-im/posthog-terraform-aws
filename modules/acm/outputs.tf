output "validation_record" {
  value = tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_name
}

output "validation_record_value" {
  value = tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_value
}