module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "elior-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "web_server_sg" {
  source      = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}




data "aws_region" "current" {}

resource "aws_security_group" "ssm_endpoint_sg" {
  name        = "ssm-endpoint-sg"
  description = "Security group for SSM endpoint, allowing traffic from public subnets"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = module.vpc.public_subnets

  security_group_ids = [aws_security_group.ssm_endpoint_sg.id]

}



resource "aws_security_group" "ecs_shared_sg" {
  name   = "ecs-shared-sg"
  vpc_id            = module.vpc.vpc_id

  # Allow inbound traffic within the same security group
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_service_discovery_private_dns_namespace" "service_connect_namespace" {
  name = "demo-namespace"
  vpc  = module.vpc.vpc_id 
}
