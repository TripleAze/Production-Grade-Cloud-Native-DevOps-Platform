variable "aws_region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}


# ECR Variables
variable "ecr_name" {
  type = string
}

variable "ecr_scan_on_push" {
  type = bool
}

variable "ecr_lifecycle_policy" {
  type = string
}

variable "ecr_tags" {
  type = map(string)
}

# Route53 Variables
variable "domain_name" {
  description = "The primary domain name for the project"
  type        = string
}

# RDS-managed secret attributes are handled automatically.
# Legacy Secrets Manager variables removed.

