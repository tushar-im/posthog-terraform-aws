locals {
  availability_zones = var.availability_zones
  ec2_key_name       = "${var.project_short_name}-${var.environment}-ec2-key"
  subdomain          = "${var.project_short_name}.${var.domain_name}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}