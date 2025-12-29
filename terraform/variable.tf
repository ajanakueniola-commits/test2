variable "NGINX_ami_id" {
  description = "AMI ID for the Nginx server"
  type        = string
}

variable "JAVA_ami_id" {
  description = "AMI ID for the Java server"
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
  description = "Availability Zone for java-node"
  type        = string
}

variable "az_number3" {
  description = "Availability Zone for python-node"
  type        = string
}