variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

#############################################################
# Frontend VPC Variables
#############################################################

variable "frontend_vpc_address_space" {
  description = "The CIDR block for the frontend VPC."
  default     = "10.0.0.0/16"
}

variable "frontend_prefix" {
  description = "The prefix for the frontend resources."
  default     = "frontend"
}

variable "frontend_environment" {
  description = "The environment for the frontend resources."
  default     = "dev"
}

variable "frontend_public_subnet_cidr" {
  description = "The CIDR block for the frontend public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "frontend_private_subnet_cidr" {
  description = "The CIDR block for the frontend private subnets."
  default     = ["10.0.253.0/24", "10.0.254.0/24", "10.0.255.0/24"]
}

variable "fe_instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t2.micro"
}
