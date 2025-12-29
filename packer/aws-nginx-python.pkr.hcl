packer {
    required_version = ">=1.9.0"

    required_plugins {
        amazon = {
            source = "github.com/hashicorp/amazon"
            version = ">= 1.2.0"
        }
    }
}


#-----------------------------
# source: how we build the AMI For Nginx and GIT 
#-----------------------------

source "amazon-ebs" "nginx-git" {
    region = "us-east-2"
    instance_type = "c7i-flex.large"
    ssh_username = "ec2-user"
    source_ami  = "ami-025ca978d4c1d9825"
    ami_name = "nginx-git-by-packer-v2"
    ami_virtualization_type  = "hvm"
}


#-----------------------------
# source: how we build the AMI For Java and GIT 
#-----------------------------

source "amazon-ebs" "java-git" {
    region = "us-east-2"
    instance_type = "c7i-flex.large"
    ssh_username = "ec2-user"
    source_ami  = "ami-025ca978d4c1d9825"
    ami_name = "java-git-by-packer-v2"
    ami_virtualization_type  = "hvm"
}

#-----------------------------
# source: how we build the AMI For Python and GIT 
#-----------------------------

source "amazon-ebs" "python-git" {
    region = "us-east-2"
    instance_type = "c7i-flex.large"
    ssh_username = "ec2-user"
    source_ami  = "ami-025ca978d4c1d9825"
    ami_name = "python-git-by-packer-v2"
    ami_virtualization_type  = "hvm"
}


#------------------------------------
# build: source + provisioning to do 
#------------------------------------

build  {
    name  = "nginx-git-ami-build"
    sources = [
        "source.amazon-ebs.nginx-git" 
    ]

    provisioner "shell" {
        inline = [
            "sudo yum update -y",
            "sudo yum install nginx -y",
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx",
            "echo  '<h1> Hello from Techbleat - Built by Packer </h1>' | sudo tee /usr/share/nginx/html/index.html",
            "sudo yum install git -y"
        ]
    }

     post-processor "manifest" {
        output = "manifest.json"
    }

    post-processor "shell-local" {
        inline = ["echo 'AMI build is finished For Nginx' "]
    }

}

build  {
    name  = "java-python-git-ami-build"
    sources = [
        "source.amazon-ebs.java-git"
    ]

    provisioner "shell" {
        inline = [
            "sudo yum update -y",
            "sudo yum install java-17-amazon-corretto -y",
            "sudo yum install git -y",
        ]
    }

     post-processor "manifest" {
        output = "manifest.json"
    }

    post-processor "shell-local" {
        inline = ["echo 'AMI build is finished For Java-python' "]
    }

}

build  {
    name  = "python-git-ami-build"
    sources = [
        "source.amazon-ebs.python-git"
    ]

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

    post-processor "shell-local" {
      inline = [
        "echo 'AMI build is finished for python'"
      ]
    }

}
