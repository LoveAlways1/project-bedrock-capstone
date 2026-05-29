module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.34"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access  = true
  endpoint_private_access = true

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  addons = {
    vpc-cni = {
      before_compute = true
    }

    kube-proxy = {}

    coredns = {}

    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    bedrock_nodes = {
      name = "bedrock-nodes"

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Name = var.cluster_name
  }
}