variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "azs" {
  description = "List of availability zones to place instances into"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "packer_ami_name_pattern" {
  description = "If set, Terraform will look up an AMI by this name pattern (use % wildcard), otherwise falls back to Amazon Linux 2 image pattern. Example: 'myapp-*'"
  type        = string
  default     = ""
}

variable "packer_ami_owner" {
  description = "Owner to use when looking up the packer AMI. Use 'self' for your account. If empty, defaults to 'amazon' for regular Amazon Linux lookup."
  type        = string
  default     = ""
}
