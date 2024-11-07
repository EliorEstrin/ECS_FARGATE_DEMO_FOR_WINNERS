
module "public_ecr_app" {
  source                  = "terraform-aws-modules/ecr/aws"
  repository_force_delete = true

  repository_name = "ecsdemo-flask"
  repository_type = "public"
}

module "network" {
  source = "./network"
  vpc_name            = "elior-vpc"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  namespace_name      = "demo-namespace"
  security_group_name = "shared-sg"
}



module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "Qday-TF"

  services = {
    app = {

      assign_public_ip      = "true"
      create_security_group = false
      cpu                   = 2048
      memory                = 4096

      subnet_ids = module.network.public_subnet_ids

      enable_execute_command    = true
      tasks_iam_role_statements = local.task_exec_iam_statements
      task_exec_iam_statements  = local.task_exec_iam_statements

      container_definitions = [
        {
          name                     = "app"
          cpu                      = 1024
          memory                   = 4096
          essential                = true
          image                    = "public.ecr.aws/f5g2i5c5/ecsdemo-flask:latest"
          memory_reservation       = 2048
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
            command      = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
            interval     = 10
            timeout      = 25
            retries      = 10
            start_period = 0
          }
        }
      ]

      skip_destroy       = true
      security_group_ids = [module.network.server_sg_id]

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


    db = {
      cpu    = 2048
      memory = 4096

      subnet_ids = module.network.public_subnet_ids

      assign_public_ip      = "true"
      tasks_iam_role_statements = local.task_exec_iam_statements
      task_exec_iam_statements  = local.task_exec_iam_statements

      container_definitions = {
        postgres = {
          cpu                      = 1024
          memory                   = 1024
          essential                = true
          image                    = "postgres:13"
          readonly_root_filesystem = false
          enable_execute_command   = true
          port_mappings = [
            {
              name          = "db"
              containerPort = 5432
              protocol      = "tcp"
            }
          ]

          environment = [
            { name = "POSTGRES_USER", value = "admin" },
            { name = "POSTGRES_PASSWORD", value = "admin" },
            { name = "POSTGRES_DB", value = "admin" }
          ]
        }
      }
      skip_destroy = false

      service_connect_configuration = {
        namespace = module.network.service_connect_namespace_name
        service = {
          client_alias = {
            port     = 5432
            dns_name = "db"
          }
          port_name      = "db"
          discovery_name = "db"
        }
      }
      security_group_ids = [module.network.server_sg_id]
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
}
