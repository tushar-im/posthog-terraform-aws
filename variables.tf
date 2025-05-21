variable "region" {
  description = "Region that the resources will be created"
  type        = string
}

variable "access-key" {
  description = "AWS access-key to be used by terraform"
  type        = string
}

variable "secret-key" {
  description = "AWS secret-key to be used by terraform"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zone"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "houseworks-posthog"
}

variable "project_short_name" {
  description = "Project Short name"
  type        = string
  default     = "posthog"
}


variable "profile" {
  description = "Profile"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the database"
  type        = list(string)
}


variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-075686beab831bb7f" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "volume_size" {
  description = "EC2 volume size"
  type        = number
  default     = 8
}

variable "ssh_allowed_cidr" {
  description = "List of CIDR blocks allowed to connect via SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] #  TODOO: change this for production
}

variable "vpc_id" {
  description = "VPC used for existing project"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}


variable "environment" {
  description = "Environment name"
  type        = string

}


variable "route53_zone_id" {
  description = "Route53 zone ID"
  type        = string

}

variable "deploy_private_key" {
  description = "Deploy private key"
  type        = string
  sensitive   = true
}