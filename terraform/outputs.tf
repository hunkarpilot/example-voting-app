# EKS Cluster Outputs
# output "cluster_name" {
#   description = "EKS cluster name"
#   value       = module.eks_al2023.cluster_name
# }

# output "cluster_endpoint" {
#   description = "EKS cluster endpoint"
#   value       = module.eks_al2023.cluster_endpoint
# }

# output "cluster_certificate_authority_data" {
#   description = "Base64 encoded certificate data required to communicate with the cluster"
#   value       = module.eks_al2023.cluster_certificate_authority_data
#   sensitive   = true
# }

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

# ECR Repository Outputs
output "ecr_repository_urls" {
  description = "ECR repository URLs for the voting app images"
  value = {
    for repo_name, repo in module.ecr : repo_name => repo.repository_url
  }
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# AWS Account Info
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = "eu-west-2"
}
