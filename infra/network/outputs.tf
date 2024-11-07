output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "service_connect_namespace_name" {
  description = "The name of the service discovery private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.service_connect_namespace.name
}


output "server_sg_id" {
  description = "The ID of the web server security group with HTTP open"
  value       = aws_security_group.shared_sg.id
}
