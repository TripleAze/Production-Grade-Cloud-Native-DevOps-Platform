vpc_name   = "solo-devops-vpc"
vpc_cidr   = "70.0.0.0/16"
aws_region = "us-east-1"

azs = ["us-east-2a", "us-east-2b"]

private_subnets = ["70.0.1.0/24", "70.0.2.0/24"]
public_subnets  = ["70.0.101.0/24", "70.0.102.0/24"]

cluster_name       = "solo-devops-eks"
kubernetes_version = "1.33"

instance_type = "t3.medium"
min_size      = 1
max_size      = 3
desired_size  = 2

environment = "dev"
project     = "solo-devops"