variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the database"
  type        = list(string)
}

variable "ssh_allowed_cidr" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
}

variable "name_prefix" {
  description = "Name prefix for the resources"
  type        = string
}