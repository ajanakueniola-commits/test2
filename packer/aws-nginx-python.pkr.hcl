packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

# -----------------------------
# SOURCES
# -----------------------------

locals {
  region        = "us-east-2"
  instance_type = "c7i-flex.large"
  base_ami      = "ami-025ca978d4c1d9825"
  ssh_user      = "ec2-user"
}

source "amazon-ebs" "nginx-git-1" {
  region        = local.region
  instance_type = local.instance_type
  ssh_username  = local.ssh_user
  source_ami    = local.base_ami
  ami_name      = "nginx-git-1-by-packer-{{timestamp}}"
}

source "amazon-ebs" "nginx-git-2" {
  region        = local.region
  instance_type = local.instance_type
  ssh_username  = local.ssh_user
  source_ami    = local.base_ami
  ami_name      = "nginx-git-2-by-packer-{{timestamp}}"
}

source "amazon-ebs" "python-git-1" {
  region        = local.region
  instance_type = local.instance_type
  ssh_username  = local.ssh_user
  source_ami    = local.base_ami
  ami_name      = "python-git-1-by-packer-{{timestamp}}"
}

source "amazon-ebs" "python-git-2" {
  region        = local.region
  instance_type = local.instance_type
  ssh_username  = local.ssh_user
  source_ami    = local.base_ami
  ami_name      = "python-git-2-by-packer-{{timestamp}}"
}

source "amazon-ebs" "jenkins-server" {
  region        = local.region
  instance_type = local.instance_type
  ssh_username  = local.ssh_user
  source_ami    = local.base_ami
  ami_name      = "jenkins-server-by-packer-{{timestamp}}"
}

# -----------------------------
# BUILDS – NGINX
# -----------------------------

build {
  name    = "nginx-git-1-ami-build"
  sources = ["source.amazon-ebs.nginx-git-1"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx git",
      "sudo systemctl enable nginx",
      "echo '<h1>Hello from Techbleat</h1>' | sudo tee /usr/share/nginx/html/index.html"
    ]
  }

  post-processor "manifest" {
    output = "nginx-git-1-manifest.json"
  }
}

build {
  name    = "nginx-git-2-ami-build"
  sources = ["source.amazon-ebs.nginx-git-2"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx git",
      "sudo systemctl enable nginx"
    ]
  }

  post-processor "manifest" {
    output = "nginx-git-2-manifest.json"
  }
}

# -----------------------------
# BUILDS – PYTHON
# -----------------------------

build {
  name    = "python-git-1-ami-build"
  sources = ["source.amazon-ebs.python-git-1"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3 git"
    ]
  }

  post-processor "manifest" {
    output = "python-git-1-manifest.json"
  }
}

build {
  name    = "python-git-2-ami-build"
  sources = ["source.amazon-ebs.python-git-2"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3 git"
    ]
  }

  post-processor "manifest" {
    output = "python-git-2-manifest.json"
  }
}

# -----------------------------
# BUILD – JENKINS SERVER
# -----------------------------

build {
  name    = "jenkins-server-ami-build"
  sources = ["source.amazon-ebs.jenkins-server"]

  provisioner "shell" {
    inline = [
      "set -eux",
      "sudo yum update -y",
      "sudo yum install -y java-11-amazon-corretto git",

      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",

      "sudo yum install -y jenkins",
      "sudo systemctl enable jenkins",

      "sudo yum install -y yum-utils shadow-utils",
      "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
      "sudo yum install -y terraform packer"
    ]
  }

  post-processor "manifest" {
    output = "jenkins-manifest.json"
  }
}
