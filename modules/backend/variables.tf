variable "name_prefix" {
  description = "Prefix for resource names, typically project-workspace"
  type        = string
}

variable "environment" {
  description = "Environment name (staging/production)"
  type        = string
}

variable "region" {
  description = "Region that the resources will be created"
  type        = string
}