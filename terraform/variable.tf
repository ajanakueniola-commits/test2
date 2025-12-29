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

variable "az_number1" {
description = "Availability Zone for web-node"
type        = string
}

variable "az_number2" {
description = "Availability Zone for python-node"
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
