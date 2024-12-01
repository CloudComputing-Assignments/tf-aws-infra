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

variable "aws_account_number"{
  description = "AWS Account Number"
  type = number
}

variable "sendgrid_api" {
  description = "Sendgrid API key"
  type = string
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

variable "asg_max_size" {
  description = "maximum number of instances for auto scaling"
  type = number
}

variable "asg_min_size" {
  description = "minimum number of instances for auto scaling"
  type = number
}

variable "asg_default_cooldown" {
  description = "cooldown period for autoscaling group"
  type = number
}

variable "asg_desired_capacity" {
  description = "desired number of instances for auto scaling"
  type = number
}

variable "scaling_out_adjustment" {
  description = "Number of instances to spawn when scaling out"
  type = number
}

variable "scaling_evaluation_period" {
  description = "Evaluation period when scaling out"
  type = number
}

variable "scaling_period" {
  description = "Scaling period for instances"
  type = number
}

variable "scale_out_threshold" {
  description = "Threshold value when scaling out"
  type = number
}

variable "scale_in_threshold" {
  description = "Threshold value when scaling in"
  type = number
}

variable "scaling_in_adjustment" {
  description = "Number of instances to destroy when scaling in"
  type = number
}

variable "launch_template_instance_type" {
  description = "Instance type for ec2 launch template"
  type = string
}

variable "ebs_volume_size" {
  description = "Volume size for ebs"
  type = number
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for load balancer health check"
  type = number
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for load balancer health check"
  type = number
}

variable "health_check_interval" {
  description = "Interval for load balancer health check"
  type = number
}

variable "health_check_timeout" {
  description = "Timeout for load balancer health check"
  type = number
}

variable "load_balancer_tg_port" {
  description = "Port for load balancer target group"
  type = number
}

variable "health_check_protocol" {
  description = "Protocol for load balancer health check"
  type = string
}

variable "health_check_path" {
  description = "Port for instance health check"
  type = string
}

variable "random_password_length" {
  description = "Password length for RDS database"
  type = number
}

variable "iam_username" {
  description = "User name for IAM"
  type = string
}