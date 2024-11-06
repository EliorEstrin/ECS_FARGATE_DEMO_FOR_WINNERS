output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}


output "ecs_shared_sg_id" {
  description = "The ID of the shared security group for ECS"
  value       = aws_security_group.ecs_shared_sg.id
}

output "web_server_sg_id" {
  description = "The ID of the web server security group with HTTP open"
  value       = module.web_server_sg.security_group_id
}

output "service_connect_namespace_name" {
  description = "The name of the service discovery private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.service_connect_namespace.name
}

