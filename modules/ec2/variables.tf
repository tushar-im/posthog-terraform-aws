variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be launched"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string

}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

}

variable "volume_size" {
  description = "EC2 volume size"
  type        = number
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group from the security module"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "deploy_private_key" {
  description = "Deploy private key"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain name of the project."
  type        = string
}
