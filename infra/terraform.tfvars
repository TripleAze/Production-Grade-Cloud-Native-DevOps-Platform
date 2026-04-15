# VPC and EKS values
vpc_name   = "solo-devops-vpc"
vpc_cidr   = "70.0.0.0/16"
aws_region = "us-east-1"

azs = ["us-east-1a", "us-east-1b"]

private_subnets = ["70.0.1.0/24", "70.0.2.0/24"]
public_subnets  = ["70.0.101.0/24", "70.0.102.0/24"]

cluster_name       = "solo-devops-eks"
kubernetes_version = "1.35"

environment = "dev"
project     = "solo-devops"

# RDS values
db_name                = "abudb"
username               = "user"
port                   = 3306
instance_class         = "db.t3.micro"
allocated_storage      = 5
backup_window          = "03:00-06:00"
maintenance_window     = "Mon:00:00-Mon:03:00"
monitoring_interval    = "30"
monitoring_role_name   = "MyRDSMonitoringRole"
create_db_subnet_group = true

family                 = "mysql8.0"
engine                 = "mysql"
engine_version         = "8.0"
major_engine_version   = "8.0"
deletion_protection    = false
create_monitoring_role = true


# ECR values
ecr_name         = "solo-devops"
ecr_scan_on_push = true

ecr_lifecycle_policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v"],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

ecr_tags = {
  Terraform = "true"
}

# Secrets Manager values
secrets_manager_name_prefix             = "solo-devops-rds-secret"
secrets_manager_description             = "Rotated Secrets Manager secret"
secrets_manager_recovery_window_in_days = 7
