# VPC and EKS values
vpc_name   = "solo-devops-vpc"
vpc_cidr   = "70.0.0.0/16"
aws_region  = "us-east-1"
domain_name = "abu-eks.cloud-ip.cc"

azs = ["us-east-1a", "us-east-1b"]

private_subnets = ["70.0.1.0/24", "70.0.2.0/24"]
public_subnets  = ["70.0.101.0/24", "70.0.102.0/24"]

cluster_name       = "solo-devops-eks"
kubernetes_version = "1.35"

environment = "dev"
project     = "solo-devops"

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


# RDS Management: AWS now handles Secrets Manager automatically.
# No manual secret variables required which improves security.

