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
    version = "5.30.0"
  }
}
}
provider "aws" {
  region = "us-east-2"
}

# --------------------------------------------------
# AMI LOOKUPS
# --------------------------------------------------

# Jenkins AMI from Packer
data "aws_ami" "jenkins" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-server-by-packer-*"]
  }
}

# Fallback AMI for nginx/python (existing logic)
data "aws_ami" "packer_or_amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --------------------------------------------------
# NETWORKING
# --------------------------------------------------

resource "aws_vpc" "grace" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "Grace-vpc" }
}

resource "aws_subnet" "grace_public" {
  vpc_id                  = aws_vpc.grace.id
  availability_zone       = var.azs[0]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "grace-public-sub" }
}

resource "aws_subnet" "grace_public_2" {
  vpc_id                  = aws_vpc.grace.id
  availability_zone       = var.azs[1]
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "grace-public-sub-2" }
}

resource "aws_subnet" "grace_private" {
  vpc_id            = aws_vpc.grace.id
  availability_zone = var.azs[0]
  cidr_block        = "10.0.3.0/24"
  tags = { Name = "grace-private-sub" }
}

resource "aws_subnet" "grace_private_2" {
  vpc_id            = aws_vpc.grace.id
  availability_zone = var.azs[1]
  cidr_block        = "10.0.4.0/24"
  tags = { Name = "grace-private-sub-2" }
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

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.grace_public_2.id
  route_table_id = aws_route_table.public.id
}

locals {
  subnet_ids = [
    aws_subnet.grace_public.id,
    aws_subnet.grace_public_2.id
  ]
}

# --------------------------------------------------
# SECURITY GROUPS
# --------------------------------------------------

resource "aws_security_group" "web_sg" {
  name_prefix = "grace-web-"
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

resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg-"
  vpc_id      = aws_vpc.grace.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# --------------------------------------------------
# EC2 INSTANCES
# --------------------------------------------------

resource "aws_instance" "nginx" {
  count                  = 2
  ami                    = data.aws_ami.packer_or_amazon.id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "nginx-${count.index}"
  }
}

resource "aws_instance" "python" {
  count                  = 2
  ami                    = data.aws_ami.packer_or_amazon.id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "python-${count.index}"
  }
}

# -------------------------
# Jenkins Server
# -------------------------
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.jenkins.id
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.grace_public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "grace-jenkins-server"
  }
}

# --------------------------------------------------
# RDS POSTGRES
# --------------------------------------------------

resource "aws_security_group" "postgres_sg" {
  name_prefix = "grace-postgres-"
  vpc_id      = aws_vpc.grace.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "grace-postgres-subnet-group"
  subnet_ids = [
    aws_subnet.grace_private.id,
    aws_subnet.grace_private_2.id
  ]
}

resource "aws_db_instance" "postgres" {
  identifier             = "grace-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}

# --------------------------------------------------
# OUTPUTS
# --------------------------------------------------

output "nginx_public_ips" {
  value = aws_instance.nginx[*].public_ip
}

output "python_public_ips" {
  value = aws_instance.python[*].public_ip
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}