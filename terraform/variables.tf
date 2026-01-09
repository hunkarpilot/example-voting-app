locals {
  name         = "talent-${var.candidate_id}"
  cluster_name = local.name

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  repos = [
    "bion-talent-${var.candidate_id}-voting-app",
    "bion-talent-${var.candidate_id}-result-app",
    "bion-talent-${var.candidate_id}-worker",
  ]

  tags = {
    candidate_id = var.candidate_id
    enviroment   = "case"
    owner        = "hunkardoner"
  }
}

variable "eks_cluster_role_arn" {
  default = "arn:aws:iam::130575395405:role/bion-talent-eks-cluster-role"
}

variable "eks_node_role_arn" {
  default = "arn:aws:iam::130575395405:role/bion-talent-eks-node-role"
}