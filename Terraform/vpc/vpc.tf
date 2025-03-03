
resource "aws_vpc" "ecs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ECS-VPC"
  }
}

resource "aws_subnet" "ecs_subnet_1" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ECS-Public-Subnet-1"
  }
}

resource "aws_subnet" "ecs_subnet_2" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ECS-Public-Subnet-2"
  }
}

# Output subnet IDs so they can be used in main.tf
output "public_subnet_1_id" {
  value = aws_subnet.ecs_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.ecs_subnet_2.id
}

output "vpc_id" {
  value = aws_vpc.ecs_vpc.id
}
