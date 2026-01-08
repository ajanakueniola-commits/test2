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

// Lookup AMI: prefer a Packer-generated AMI when `var.packer_ami_name_pattern` is set,
// otherwise fall back to the Amazon Linux 2 pattern.
data "aws_ami" "packer_or_amazon" {
  most_recent = true

  owners = var.packer_ami_owner != "" ? [var.packer_ami_owner] : ["amazon"]

  filter {
    name = "name"
    values = [
      var.packer_ami_name_pattern != "" ? var.packer_ami_name_pattern : "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
}

// VPC and subnets
resource "aws_vpc" "grace" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Grace-vpc"
  }
}

resource "aws_subnet" "grace_public" {
  vpc_id                  = aws_vpc.grace.id
  availability_zone       = var.azs[0]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "grace-public-sub"
  }
}

resource "aws_subnet" "grace_public_2" {
  vpc_id                  = aws_vpc.grace.id
  availability_zone       = var.azs[1]
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "grace-public-sub-2"
  }
}

resource "aws_subnet" "grace_private" {
  vpc_id                  = aws_vpc.grace.id
  availability_zone       = var.azs[0]
  cidr_block              = "10.0.3.0/24"
  tags = {
    Name = "grace-private-sub"
  }
}

resource "aws_subnet" "grace_private_2" {
  vpc_id                  = aws_vpc.grace.id
  availability_zone       = var.azs[1]
  cidr_block              = "10.0.4.0/24"

  tags = {
    Name = "grace-private-sub-2"
  }
}

resource "aws_internet_gateway" "grace_igw" {
  vpc_id = aws_vpc.grace.id
  tags   = { Name = "grace-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.grace.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grace_igw.id
  }
  tags = { Name = "grace-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.grace_public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  name        = "nginx-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.grace.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  subnet_ids = [aws_subnet.grace_public.id, aws_subnet.grace_public_2.id]
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.grace_public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "nginx" {
  count                       = 2
  ami                         = data.aws_ami.packer_or_amazon.id
  instance_type               = var.instance_type
  # availability_zone omitted — let AWS infer from subnet to avoid AZ mismatch
  subnet_id                   = local.subnet_ids[count.index]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install -y nginx1
    systemctl enable nginx
    systemctl start nginx
    echo "Hello from nginx instance ${count.index}" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "nginx-${count.index}"
  }
}

output "nginx_public_ips" {
  description = "Public IPs of NGINX instances"
  value       = aws_instance.nginx.*.public_ip
}

resource "aws_instance" "python" {
  count                       = 2
  ami                         = data.aws_ami.packer_or_amazon.id
  instance_type               = var.instance_type
  # availability_zone omitted — let AWS infer from subnet to avoid AZ mismatch
  subnet_id                   = local.subnet_ids[count.index]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install -y python3
    python3 -m venv .venv
    source .venv/bin/activate
    python -m pip install -r requirements.txt
    uvicorn main:app --host 0.0.0.0 --port 8000 & reload
  EOF

  tags = {
    Name = "python-${count.index}"
  }
}

output "python_public_ips" {
  description = "Public IPs of PYTHON instances"
  value       = aws_instance.python.*.public_ip
}

