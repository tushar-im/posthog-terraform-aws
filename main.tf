terraform {
  # This sets the version constraint to a minimum of 1.10 for native state file locking support
  required_version = "~> 1.10"
}

# Backend Module (First, for state management)
module "backend" {
  source      = "./modules/backend"
  name_prefix = var.project_short_name
  environment = var.environment
  region      = var.region
}

# Provider Block
provider "aws" {
  profile    = var.profile
  access_key = var.access-key
  secret_key = var.secret-key
  region     = var.region
}


# Security Module (depends on VPC)
module "security" {
  source              = "./modules/security"
  name_prefix         = var.project_short_name
  environment         = var.environment
  vpc_id              = var.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
  ssh_allowed_cidr    = var.ssh_allowed_cidr
}

# Compute Module (depends on VPC, Security, IAM, S3)
module "ec2" {
  source             = "./modules/ec2"
  name_prefix        = var.project_short_name
  domain_name        = var.domain_name
  environment        = var.environment
  vpc_id             = var.vpc_id
  subnet_id          = data.aws_subnet.selected.id
  security_group_id  = module.security.security_group_id
  key_name           = local.ec2_key_name
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  volume_size        = var.volume_size
  deploy_private_key = var.deploy_private_key
}

# ACM Module
module "acm" {
  source          = "./modules/acm"
  name_prefix     = var.project_short_name
  domain_name     = local.subdomain
  route53_zone_id = var.route53_zone_id
  environment     = var.environment
}

# Route53 Module (depends on EC2)
module "route53" {
  source = "./modules/route53"

  route53_zone_id = var.route53_zone_id
  name_prefix     = var.project_short_name
  domain_name     = var.domain_name
  ec2_public_ip   = module.ec2.public_ip
  environment     = var.environment
}