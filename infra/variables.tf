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

variable "instance_type" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_size" {
  type = number
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

# RDS Variables
variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "port" {
  type = number
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = null
}

variable "backup_window" {
  type = string
}

variable "maintenance_window" {
  type = string
}

variable "monitoring_interval" {
  type = string
}

variable "monitoring_role_name" {
  type = string
}

variable "create_monitoring_role" {
  type = bool
}

variable "create_db_subnet_group" {
  type = bool
}

variable "family" {
  type = string
}

variable "major_engine_version" {
  type = string
}

variable "deletion_protection" {
  type = bool
}

variable "engine" {
  type = string
}

variable "engine_version" {
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

# Secrets Manager Variables
variable "secrets_manager_name_prefix" {
  type = string
}

variable "secrets_manager_description" {
  type = string
}

variable "secrets_manager_recovery_window_in_days" {
  type = number
}

