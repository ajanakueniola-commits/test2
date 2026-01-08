packer {
  required_version = ">=1.9.0"

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

source "amazon-ebs" "nginx-git-1" {
  region                  = "us-east-2"
  instance_type           = "c7i-flex.large"
  ssh_username            = "ec2-user"
  source_ami              = "ami-025ca978d4c1d9825"
  ami_name                = "nginx-git-1-by-packer-v1"
  ami_virtualization_type = "hvm"
}

source "amazon-ebs" "nginx-git-2" {
  region                  = "us-east-2"
  instance_type           = "c7i-flex.large"
  ssh_username            = "ec2-user"
  source_ami              = "ami-025ca978d4c1d9825"
  ami_name                = "nginx-git-2-by-packer-v2"
  ami_virtualization_type = "hvm"
}

source "amazon-ebs" "python-git-1" {
  region                  = "us-east-2"
  instance_type           = "c7i-flex.large"
  ssh_username            = "ec2-user"
  source_ami              = "ami-025ca978d4c1d9825"
  ami_name                = "python-git-1-by-packer-v1"
  ami_virtualization_type = "hvm"
}

source "amazon-ebs" "python-git-2" {
  region                  = "us-east-2"
  instance_type           = "c7i-flex.large"
  ssh_username            = "ec2-user"
  source_ami              = "ami-025ca978d4c1d9825"
  ami_name                = "python-git-2-by-packer-v2"
  ami_virtualization_type = "hvm"
}

source "amazon-ebs" "jenkins-server" {
  region                  = "us-east-2"
  instance_type           = "c7i-flex.large"
  ssh_username            = "ec2-user"
  source_ami              = "ami-025ca978d4c1d9825"
  ami_name                = "jenkins-server-by-packer"
  ami_virtualization_type = "hvm"
}
# -----------------------------
# BUILDS
# -----------------------------

build {
  name    = "nginx-git-1-ami-build"
  sources = ["source.amazon-ebs.nginx-git-1"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo '<h1>Hello from Techbleat - Built by Packer</h1>' | sudo tee /usr/share/nginx/html/index.html",
      "sudo yum install git -y"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}

build {
  name    = "nginx-git-2-ami-build"
  sources = ["source.amazon-ebs.nginx-git-2"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo '<h1>Hello from Techbleat - Built by Packer</h1>' | sudo tee /usr/share/nginx/html/index.html",
      "sudo yum install git -y"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}

build {
  name    = "python-git-1-ami-build"
  sources = ["source.amazon-ebs.python-git-1"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install python3 -y",
      "sudo yum install git -y"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}

build {
  name    = "python-git-2-ami-build"
  sources = ["source.amazon-ebs.python-git-2"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install python3 -y",
      "sudo yum install git -y"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}

build {
  name    = "jenkins-server-ami-build"
  sources = ["source.amazon-ebs.jenkins-server"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install java-11-amazon-corretto -y",
      "sudo yum install git -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
"sudo yum install jenkins -y",
"sudo systemctl enable jenkins",
"sudo systemctl start jenkins",
"sudo yum install -y yum-utils shadow-utils",
"sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
"sudo yum install packer -y",
"sudo yum install -y yum-utils shadow-utils",
"sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
"sudo yum install terraform -y"

    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}