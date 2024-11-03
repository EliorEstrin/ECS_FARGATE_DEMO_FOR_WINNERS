terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}


module "public_ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "ecsdemo-flask"
  repository_type = "public"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
