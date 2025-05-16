################
# EKS Module 
################

module "eks" {
  source                                 = "git::https://github.com/nasir19noor/terraform.git//aws/modules/eks"
  cluster_name                           = local.cluster_name
  cluster_version                        = local.cluster_version
  # cloudwatch_log_group_retention_in_days = local.cloudwatch_log_group_retention_in_days

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns    = {}
  }

  vpc_id                        = local.vpc_id
  subnet_ids                    = [local.subnet-1_id, local.subnet-2_id]
  control_plane_subnet_ids      = [local.subnet-1_id, local.subnet-2_id]
  create_cluster_security_group = local.create_cluster_security_group
  create_node_security_group    = local.create_node_security_group

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = []
    
    # Add the additional IAM policy
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  eks_managed_node_groups = {
    # Primary node group - runs critical system pods
    system = {
      name = "system-nodes"
      
      min_size     = 1
      max_size     = 1
      desired_size = 1

      subnet_ids = [local.subnet-1_id, local.subnet-2_id]
      capacity_type = "ON_DEMAND"

      labels = {
        role = "system"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }
    }

    # Application node group - runs your application workloads
    app = {
      name = "app-nodes"
      
      min_size     = 1
      max_size     = 1
      desired_size = 1

      subnet_ids = [local.subnet-1_id, local.subnet-2_id]

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "app"
        namespace = "nasir"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "app"
          effect = "NO_SCHEDULE"
        }
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }
    }
  }

  
  cluster_security_group_additional_rules = {
    ingress_custom_rule_1 = {
      description = "Allow inbound traffic from Azure pipeline agent"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["10.0.0.0/16"]
      type        = "ingress"
    }  
  }
  
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Create EKS Admin IAM Role
resource "aws_iam_role" "eks_admin_role" {
  name = "${local.cluster_name}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {}
      },
    ]
  })

  tags = {
    Name = "${local.cluster_name}-admin-role"
  }
}

# Attach Amazon EKS cluster policy to admin role
resource "aws_iam_role_policy_attachment" "eks_admin_amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_admin_role.name
}

# Attach Amazon EKS service policy to admin role
resource "aws_iam_role_policy_attachment" "eks_admin_amazon_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_admin_role.name
}

# Attach Admin access policy to the role
resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
  policy_arn = aws_iam_policy.eks_admin_policy.arn
  role       = aws_iam_role.eks_admin_role.name
}

# Create custom policy for EKS admin
resource "aws_iam_policy" "eks_admin_policy" {
  name        = "${local.cluster_name}-admin-policy"
  description = "Policy that gives full access to EKS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "iam:ListRoles"
        ]
        Resource = "*"
      }
    ]
  })
}

# Add Kubernetes provider to manage aws-auth ConfigMap
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
  }
}

# Create aws-auth ConfigMap to map IAM roles to Kubernetes RBAC
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [module.eks]
  
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      concat(
        [
          {
            rolearn  = aws_iam_role.eks_admin_role.arn
            username = "cluster-admin"
            groups   = ["system:masters"]
          }
        ],
        # Include the node role mappings that EKS creates
        [
          {
            rolearn  = module.eks.eks_managed_node_groups["system"].iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
          },
          {
            rolearn  = module.eks.eks_managed_node_groups["app"].iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
          }
        ]
      )
    )
  }
}

# Additional policy for node groups
resource "aws_iam_policy" "additional" {
  name = "${local.cluster_name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Output the admin role ARN for use in assume role commands
