variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "ec2_public_ip" {
  description = "EC2 instance public IP"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for the resources"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone ID"
  type        = string

}