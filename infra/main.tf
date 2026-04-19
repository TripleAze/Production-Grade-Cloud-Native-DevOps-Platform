module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1 # for alb controller to identify where to create alb
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1 # for alb controller to identify where to create internal alb
  }
  tags = {
    Name = "solo-devops-vpc"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access  = true
  endpoint_private_access = true

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  tags = {
    environment = var.environment
    project     = var.project
  }
}

module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name                      = "external-secrets-operator"
  attach_external_secrets_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-secrets"]
    }
  }
}

module "load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name                              = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


resource "aws_route53_zone" "primary" {
  name = "abu-eks.cloud-ip.cc"
}

# Generate SSL Cert using the standard module
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = aws_route53_zone.primary.name
  zone_id     = aws_route53_zone.primary.zone_id

  # Validates the cert automatically via Route 53
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${aws_route53_zone.primary.name}",
  ]

  wait_for_validation = true
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.0"

  identifier = "solo-devops"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.username
  port     = var.port

  iam_database_authentication_enabled = true
  manage_master_user_password         = true

  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id]

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = var.monitoring_role_name
  create_monitoring_role = var.create_monitoring_role

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = var.create_db_subnet_group
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = var.family

  # DB option group
  major_engine_version = var.major_engine_version

  # Database Deletion Protection
  deletion_protection = var.deletion_protection

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}


module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_name

  repository_image_scan_on_push     = var.ecr_scan_on_push
  repository_lifecycle_policy       = var.ecr_lifecycle_policy

  repository_image_tag_mutability = "MUTABLE"

  tags = var.ecr_tags
}

# RDS-managed secrets handle individual attributes like username, password, host, and dbname
# so i no longer need a manually provisioned Secrets Manager module here.
resource "aws_security_group_rule" "ingress_load_balancer" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = module.eks.cluster_primary_security_group_id
  description       = "Allow ALB to talk to Pods on port 80"
}

resource "aws_security_group_rule" "ingress_load_balancer_api" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = module.eks.cluster_primary_security_group_id
  description       = "Allow ALB to talk to Pods on port 8080"
}
