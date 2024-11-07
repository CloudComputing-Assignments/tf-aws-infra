variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
}

variable "public_key" {
  description = "AWS public key"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" 
}

# Define the custom AMI ID
variable "custom_ami_id" {
  description = "Custom AMI ID for EC2"
  type        = string
}

variable "domain_name" {
  description = "domain name for A record"
  type        = string
}
