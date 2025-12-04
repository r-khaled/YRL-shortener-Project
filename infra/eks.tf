# =====================================================
# EKS Cluster Definition
# =====================================================

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = concat(values(aws_subnet.public)[*].id, values(aws_subnet.private)[*].id)
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]

  tags = {
    Name = "${var.cluster_name}"
  }
}

# =====================================================
# EKS Managed Node Group
# =====================================================

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = values(aws_subnet.private)[*].id

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = 1
    max_size     = 3
  }

  instance_types = [var.node_instance_type]

  disk_size = 20

  remote_access {
    ec2_ssh_key = ""  # Set to your EC2 key pair name if needed for SSH access
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}
