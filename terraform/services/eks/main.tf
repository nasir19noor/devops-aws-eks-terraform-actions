module "eks" {
  source  = "git::https://github.com/nasir19noor/terraform.git//aws/modules/eks"

  cluster_name    = local.name
  cluster_version = "1.32"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = local.vpc_id
  subnet_ids = [local.subnet-1_id, local.subnet-2_id]

  eks_managed_node_groups = {
    nasir = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.small"]

      min_size = 1
      max_size = 2
      desired_size = 1
    }
  }
}

  # Access Entries for EKS API
  access_entries = {
    nasir = {
      principal_arn     = "arn:aws:iam::593793047751:user/nasir"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }