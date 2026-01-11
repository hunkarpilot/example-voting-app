resource "aws_eks_cluster" "this" {
  name     = local.name
  role_arn = var.eks_cluster_role_arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = false
  }

  tags = local.tags
}

resource "aws_eks_node_group" "talent" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "talent-${var.candidate_id}-ng"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  instance_types = ["t3.xlarge"]
  ami_type       = "AL2023_x86_64_STANDARD"

  labels = {
    candidate_id = var.candidate_id
  }

  tags = local.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = local.tags
  depends_on = [ aws_eks_node_group.talent ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = local.tags
  depends_on = [ aws_eks_node_group.talent ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = local.tags
  depends_on = [ aws_eks_node_group.talent ]
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = local.tags
  depends_on = [ aws_eks_node_group.talent ]
}

resource "aws_eks_access_entry" "talent_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = "arn:aws:iam::130575395405:role/talent_role"
  type          = "STANDARD"

  tags = local.tags
}

resource "aws_eks_access_policy_association" "talent_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.talent_admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}