module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name           = var.vpc_name
  cidr           = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnet_cidrs
}

resource "aws_service_discovery_private_dns_namespace" "service_connect_namespace" {
  name = var.namespace_name
  vpc  = module.vpc.vpc_id
}

resource "aws_security_group" "shared_sg" {
  name   = var.security_group_name
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

