
module "public_ecr_app" {
  source                  = "terraform-aws-modules/ecr/aws"
  repository_force_delete = true

  repository_name = "ecsdemo-flask"
  repository_type = "public"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "public_ecr_db" {
  source = "terraform-aws-modules/ecr/aws"

  repository_force_delete = true
  repository_name         = "ecsdemo-db"
  repository_type         = "public"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "network" {
  source = "./network"
}



module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "Qday-TF"

  services = {
    app = {                                 # Define each service by name
      cpu    = 2048
      memory = 4096

      subnet_ids = module.network.public_subnet_ids

      enable_execute_command = true
      tasks_iam_role_statements = local.task_exec_iam_statements
      task_exec_iam_statements  = local.task_exec_iam_statements

      container_definitions = [
        {
          name                    = "app"
          cpu                     = 1024
          memory                  = 4096
          essential               = true
          image                   = "public.ecr.aws/f5g2i5c5/ecsdemo-flask:latest"
          memory_reservation      = 2048
          readonly_root_filesystem = false

          port_mappings = [
            {
              name          = "app"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          environment = [
            { name = "DB_HOST", value = "db" },
            { name = "DB_NAME", value = "admin" },
            { name = "DB_USER", value = "admin" },
            { name = "DB_PASS", value = "admin" }
          ]

          health_check = {
            command      = ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"]
            interval     = 10
            timeout      = 25
            retries      = 10
            start_period = 0
          }
        }
      ]

      skip_destroy = true

      security_group_ids = [module.network.ecs_shared_sg_id, module.network.web_server_sg_id]

      security_group_rules = [
        local.allow_all_outbound
      ]

      service_connect_configuration = {
        namespace = module.network.service_connect_namespace_name
        service = {
          client_alias = {
            port     = 80
            dns_name = "app"
          }
          port_name      = "app"
          discovery_name = "app"
        }
      }
    }
  }
}


locals {
  task_exec_iam_statements = [
    {
      actions   = ["glue:*", "athena:*"]
      resources = ["*"]
    },
    {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
      resources = ["*"]
    },
    {
      actions   = ["ssm:*", "ecr:*", "ecr-public:*", "sts:GetServiceBearerToken", "ssmmessages:*"]
      resources = ["*"]
    },
    {
      actions = [
        "ecr:*",
        "ecr-public:*",
        "sts:GetServiceBearerToken"
      ]
      resources = ["*"]
    }
  ]

  allow_all_outbound = {
    type        = "egress"      # Specifies outbound traffic
    protocol    = "-1"          # -1 means all protocols
    from_port   = 0             # All ports
    to_port     = 0             # All ports
    cidr_blocks = ["0.0.0.0/0"] # Allows traffic to all IPs
  }
}
