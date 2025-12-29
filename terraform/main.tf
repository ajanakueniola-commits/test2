terraform {
  backend "s3" {
    bucket  = "funmi-cicd-state-bucket"
    key     = "envs/dev/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true

  }
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

## AMI Data Source from (Amazon Linux 2023)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#  ----------------------==
# VPC Data Source
#  ------------------------

data "aws_vpc" "default" {
  default = true
}

# -------------------------
# Web Node Security Group
# -------------------------

resource "aws_security_group" "NGINX_sg" {

  name        = "NGINX-sg"
  description = "Allow SSH and Port 80  inbound, all outbound"
  vpc_id      = data.aws_vpc.default.id


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 80 (NGINX)
  ingress {
    description = "NGINX port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NGINX-security_group"
  }

}

#-------------------------
# Web EC2 Instance
# ------------------------


resource "aws_instance" "NGINX" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  availability_zone      = var.availability_zone
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  tags = {
    Name = "terraform-nginx-node"
  }
}

# -------------------------
# Python Node Security Group
# -------------------------

resource "aws_security_group" "PYTHON_sg" {

  name        = "PYTHON-sg"
  description = "Allow SSH and Port 8080  inbound, all outbound"
  vpc_id      = data.aws_vpc.default.id

  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 80 (PYTHON)
  ingress {
    description = "PYTHON app port 8080"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PYTHON-app-security_group"
  }

}

#-------------------------
# Python EC2 Instance
# ------------------------

resource "aws_instance" "PYTHON" {
  ami                    = var.PYTHON_ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.PYTHON_sg.id]
  key_name               = var.key_name
  subnet_id             = var.subnet_id
  availability_zone     = var.availability_zone
  tags = {
    Name = "terraform-python-node"
  }
}

#--------------------------------
# Outputs - Public (external) IPs
#--------------------------------


output "NGINX_ip" {
  description = " Public IP"
  value  = aws_instance.NGINX.public_ip
}

output "PYTHON_ip" {
  description = " Public IP"
  value  = aws_instance.PYTHON.public_ip
}
