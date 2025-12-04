# IAM Roles and Policies for EKS Cluster and Node Group

# =====================================================
# EKS Cluster IAM Role
# =====================================================


resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-cluster-role"
  }
}

# Attach AmazonEKSClusterPolicy to EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach AmazonEKSServicePolicy to EKS cluster role (legacy but still required)
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# =====================================================
# EKS Node Group IAM Role
# =====================================================

resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-node-group-role"
  }
}

# Attach AmazonEKSWorkerNodePolicy to node group role
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach AmazonEKS_CNI_Policy to node group role
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach AmazonEC2ContainerRegistryReadOnly to node group role
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# =====================================================
# Optional: Custom Policy for Application-Specific Permissions
# =====================================================

# Uncomment and customize if your application needs AWS service access
# (e.g., S3, DynamoDB, Secrets Manager, CloudWatch, etc.)

# resource "aws_iam_policy" "app_custom_policy" {
#   name        = "${var.cluster_name}-app-policy"
#   description = "Custom policy for application pods"
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject"
#         ]
#         Resource = "arn:aws:s3:::my-bucket/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "app_custom_policy" {
#   role       = aws_iam_role.node_group_role.name
#   policy_arn = aws_iam_policy.app_custom_policy.arn
# }

# =====================================================
# IRSA (IAM Roles for Service Accounts) - Optional
# =====================================================

# Uncomment if you need to use IRSA for fine-grained pod-level IAM permissions

# data "tls_certificate" "cluster" {
#   url = aws_eks_cluster.this.identity[0].oidc[0].issuer
# }
#
# resource "aws_iam_openid_connect_provider" "cluster" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
# }
#
# resource "aws_iam_role" "irsa_example" {
#   name = "${var.cluster_name}-irsa-example-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.cluster.arn
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" = "system:serviceaccount:app:example-app"
#           }
#         }
#       }
#     ]
#   })
# }
