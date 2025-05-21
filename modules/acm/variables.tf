variable "domain_name" {
  description = "Domain name"
  type        = string
}
variable "route53_zone_id" {
  description = "Route 53 Zone ID"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for the resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}