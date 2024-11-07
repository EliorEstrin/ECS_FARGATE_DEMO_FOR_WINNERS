variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for the subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "namespace_name" {
  description = "Name of the service discovery namespace"
  type        = string
}

variable "security_group_name" {
  description = "Name of the shared security group"
  type        = string
}

