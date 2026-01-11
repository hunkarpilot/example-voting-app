locals {
  name         = "talent-${var.candidate_id}"
  cluster_name = local.name

  vpc_cidr = "10.0.0.0/16"
  azs      = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

  repos = [
    "bion-talent-${var.candidate_id}-voting-app",
    "bion-talent-${var.candidate_id}-result-app",
    "bion-talent-${var.candidate_id}-worker",
  ]

  tags = {
    candidate_id = var.candidate_id
    Purpose      = "candidate-assignment"
    Owner        = "candidate-hunkardoner"
    Expires      = "2026-01-12"
  }
}

variable "eks_cluster_role_arn" {
  default = "arn:aws:iam::130575395405:role/bion-talent-eks-cluster-role"
}

variable "eks_node_role_arn" {
  default = "arn:aws:iam::130575395405:role/bion-talent-eks-node-role"
}
