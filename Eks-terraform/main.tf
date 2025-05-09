# # Get the VPC data (default VPC)
# data "aws_vpc" "default" {
#   default = true
# }

# # Get all public subnets in the VPC, excluding us-east-1e
# data "aws_subnets" "public" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }

# # Identify the subnets that are not in us-east-1e
# locals {
#   valid_subnets = [for subnet in data.aws_subnets.public.ids : subnet if !(subnet == "subnet-us-east-1e-id")]  # Replace with actual subnet ID of us-east-1e
# }

# # IAM policy document for EKS control plane assume role
# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# # IAM role for the EKS control plane
# resource "aws_iam_role" "example" {
#   name               = "eks-cluster-associate"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# # Attach the AmazonEKSClusterPolicy to the EKS role
# resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.example.name
# }

# # EKS Cluster resource
# resource "aws_eks_cluster" "example" {
#   name     = "EKS_ASSOCIATE"
#   role_arn = aws_iam_role.example.arn

#   vpc_config {
#     subnet_ids = slice(local.valid_subnets, 0, 2)  # Ensure we use two subnets that do not include us-east-1e
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
#   ]
# }

# # IAM Role for Node Group
# resource "aws_iam_role" "example1" {
#   name = "eks-node-group-cloud"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# # Attach policies to Node Role
# resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.example1.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.example1.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.example1.name
# }

# # EKS Node Group
# resource "aws_eks_node_group" "example" {
#   cluster_name    = aws_eks_cluster.example.name
#   node_group_name = "Node-associate"
#   node_role_arn   = aws_iam_role.example1.arn
#   subnet_ids      = local.valid_subnets

#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }

#   instance_types = ["t2.medium"]

#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Retrieve details for each subnet
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

# Filter subnets excluding us-east-1e
locals {
  valid_subnets = [
    for s in data.aws_subnet.details :
    s.id if s.availability_zone != "us-east-1e"
  ]
}

# IAM policy for EKS cluster role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# EKS Cluster Role
resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster-associate"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "EKS_ASSOCIATE"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = slice(local.valid_subnets, 0, 2)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

# Node Group IAM Role
resource "aws_iam_role" "node_role" {
  name = "eks-node-group-cloud"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach node policies
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_ECRReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# Node Group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "Node-associate"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = local.valid_subnets

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t2.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_ECRReadOnly,
  ]
}