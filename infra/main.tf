terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

 

module "public_ecr_app" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "ecsdemo-flask"
  repository_type = "public"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "public_ecr_db" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "ecsdemo-db"
  repository_type = "public"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name = "Qday-TF"
}
