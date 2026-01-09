provider "aws" {
  region  = "eu-west-2"
  profile = "default"

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
