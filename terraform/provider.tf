provider "aws" {
  region  = "eu-west-2"
  profile = "default"

  assume_role {
    role_arn     = "arn:aws:iam::130575395405:role/talent_role"
    session_name = "HunkarAssessmentSession"
  }

  default_tags {
    tags = {
      candidate_id = var.candidate_id
      enviroment   = "case"
      owner        = "hunkardoner"
    }
  }
}

variable "candidate_id" {
  type        = string
  description = "AWS Account ID"
  default     = "904976121950"
}
