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

data "aws_region" "current" {}
