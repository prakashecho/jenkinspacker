packer {
  required_plugins {
    amazon = {
      version = ">=1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
    
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "Jenkins-AMI"
  instance_type = "t2.small"
  region        = "us-east-1"
  source_ami    = "ami-04b70fa74e45c3917"
  ssh_username  = "ubuntu"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = "22ad3ccd-28a1-4d05-ad73-5f284cea93b3"
  }
}

build {
  name    = "jenkins-build"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install openjdk-11-jdk -y",
      "sudo apt install maven wget unzip -y",
      
    ]
  }

 post-processors {
  post-processor "aws" {
    type        = "ami"
    region      = "us-east-1"  # Specify the region of the AMI

    ami_regions = ["us-east-1"]  # Regions where the AMI will be available

    filters {
      name   = "name"
      values = ["Jenkins-AMI"]  # Specify the name of the AMI
    }

    launch_permission {
      account_id = "280435798514"  # AWS account ID to share the AMI with
    }

    role_arn    = "arn:aws:iam::874599947932:role/gitaws"  # Replace with the ARN of the IAM role
  }
}
