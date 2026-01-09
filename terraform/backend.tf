terraform {
  required_version = ">= 1.3.2"

  backend "s3" {
    bucket       = "terraform-states-904976121950"
    profile      = "default"
    key          = "bion-case-904976121950"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
