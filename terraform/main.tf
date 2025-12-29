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

# -------------------------
# Web Node Security Group
# -------------------------

resource "aws_security_group" "NGINX_sg" {

  name        = "NGINX-sg"
  description = "Allow SSH and Port 80  inbound, all outbound"
  vpc_id      = "vpc-0cda215927b58205a"


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
  ami                    = var.NGINX_ami_id
  instance_type          = var.instance_type
  subnet_id              = "subnet-05321b19c9d5946ea"
  vpc_security_group_ids = [aws_security_group.NGINX_sg.id]
  key_name               = var.key_name
  availability_zone      = "us-east-2a"

  tags = {
    Name = "terraform-nginx-node"
  }
}

# -------------------------
# Java Node Security Group
# -------------------------

resource "aws_security_group" "JAVA_sg" {

  name        = "JAVA-sg"
  description = "Allow SSH and Port 9090  inbound, all outbound"
  vpc_id      = "vpc-0cda215927b58205a"


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 9090 (JAVA)
  ingress {
    description = "JAVA app port 9090"
    from_port   = 9090
    to_port     = 9090
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
    Name = "JAVA-app-security_group"
  }

}

#-------------------------
# java EC2 Instance
# ------------------------

resource "aws_instance" "JAVA" {
 ami                    = var.JAVA_ami_id
  instance_type          = var.instance_type
  subnet_id              = "subnet-05321b19c9d5946ea"
  vpc_security_group_ids = [aws_security_group.JAVA_sg.id]
  key_name               = var.key_name
  availability_zone      ="us-east-2a"

  tags = {
    Name = "terraform-java-node"
  }
}

# -------------------------
# Python Node Security Group
# -------------------------

resource "aws_security_group" "PYTHON_sg" {

  name        = "PYTHON-sg"
  description = "Allow SSH and Port 8080  inbound, all outbound"
  vpc_id      = "vpc-0cda215927b58205a"


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
    from_port   = 8080
    to_port     = 8080
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
  subnet_id              = "subnet-05321b19c9d5946ea"
  vpc_security_group_ids = [aws_security_group.PYTHON_sg.id]
  key_name               = var.key_name
  availability_zone      = "us-east-2a"
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

output "JAVAe_ip" {
  description = " Public IP"
  value  = aws_instance.JAVA.public_ip
}
