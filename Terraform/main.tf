terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"


  # Create ECR Repository
}
resource "aws_ecr_repository" "solar_system_repo" {
  name = "solar-system-repo"
}
#create ECS Cluster
resource "aws_ecs_cluster" "solar_system_cluster" {
  name = "solar-system-cluster"
}
# create IAM role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# Attach policy to IAM role
resource "aws_iam_policy_attachment" "ecs_task_execution_role_attachment" {
  name       = "ecs_task_execution_role_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
}
#Define task definition
resource "aws_ecs_task_definition" "solar_system_task_definition" {
  family = "solar-system-task"
  container_definitions = jsonencode([
    {
      name      = "solar-system-container"
      image     = aws_ecr_repository.solar_system_repo.repository_url
      cpu       = 256
      memory    = 512
      essential = true
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "512"
  cpu                      = "256"
}

module "vpc" {
  source = "./vpc" # Path to your vpc.tf file
}
# Define the security group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_sg"
  }
}

# create ECS service    
resource "aws_ecs_service" "solar_system_service" {
  name            = "solar-system-service"
  cluster         = aws_ecs_cluster.solar_system_cluster.id
  task_definition = aws_ecs_task_definition.solar_system_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}