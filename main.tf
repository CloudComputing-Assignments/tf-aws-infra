provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # or any profile you need
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.tags
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "my-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "my-private-route-table"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count = 3

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count = 3

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "my-private-subnet-${count.index + 1}"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association" {
  count = 3

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_association" {
  count = 3

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Create the Application Security Group
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "app-sg"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    //cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb_sg.id]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  tags = {
    Name = "NAT-EIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "NAT-Gateway"
  }
}

# Update Private Route Table to Route to NAT Gateway
resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

data "aws_caller_identity" "current" {}