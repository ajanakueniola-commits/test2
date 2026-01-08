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
    instance_type           = "t3.small"
    ssh_username            = "ec2-user"
    source_ami              = "ami-025ca978d4c1d9825"
    ami_name                = "nginx-git-1-by-packer-v1"
    ami_virtualization_type = "hvm"
}

source "amazon-ebs" "nginx-git-2" {
    region                  = "us-east-2"
    instance_type           = "t3.small"
    ssh_username            = "ec2-user"
    source_ami              = "ami-025ca978d4c1d9825"
    ami_name                = "nginx-git-2-by-packer-v2"
    ami_virtualization_type = "hvm"
}

source "amazon-ebs" "python-git-1" {
    region                  = "us-east-2"
    instance_type           = "t3.small"
    ssh_username            = "ec2-user"
    source_ami              = "ami-025ca978d4c1d9825"
    ami_name                = "python-git-1-by-packer-v1"
    ami_virtualization_type = "hvm"
}

source "amazon-ebs" "python-git-2" {
    region                  = "us-east-2"
    instance_type           = "t3.small"
    ssh_username            = "ec2-user"
    source_ami              = "ami-025ca978d4c1d9825"
    ami_name                = "python-git-2-by-packer-v2"
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
        output = "manifest-nginx-git-1.json"
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
        output = "manifest-nginx-git-2.json"
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
        output = "manifest-python-git-1.json"
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
        output = "manifest-python-git-2.json"
    }
}

# -----------------------------
# ✅ GLOBAL MANIFEST FOR JENKINS
# -----------------------------

post-processor "manifest" {
    output      = "manifest.json"
    strip_path  = true
}
