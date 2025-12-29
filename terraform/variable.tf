variable "NGINX_ami_id" {
  description = "AMI ID for the Nginx server"
  type        = string
}

variable "PYTHON_ami_id" {
description = "AMI ID for the Python server"
type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 SSH key name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "EC2 SSH subnet_id"
  type        = string
}

variable "availability_zone" {
  description = "EC2 SSH availability_zone"
  type        = string
}
