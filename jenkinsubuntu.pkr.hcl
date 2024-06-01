packer {
  required_plugins {
    amazon = {
      version = ">=1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
    amazon-ami-copy = {
      version = ">=v1.7.0"
      source  = "github.com/martinbaillie/ami-copy"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "Jenkins-AMI"
  instance_type = "t2.small"
  region        = "us-east-1"
  source_ami    = "ami-04b70fa74e45c3917"  # Replace this with the actual source AMI ID
  ssh_username  = "ubuntu"

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 8
    volume_type = "gp2"
    encrypted   = true
    kms_key_id  = "22ad3ccd-28a1-4d05-ad73-5f284cea93b3"
  }
}

variable "built_ami_id" {
  description = "The ID of the AMI built by Packer"
}

build {
  name    = "jenkins-build"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",  
    ]
  }

  provisioner "shell-local" {
    command = <<-EOF
      # Capture the AMI ID built by Packer
      echo "AMI_ID=$(cat ami_id.txt)" >> packer_output.txt
    EOF
  }

  provisioner "file" {
    source      = "/dev/null"
    destination = "ami_id.txt"
  }

  provisioner "file" {
    source      = "/dev/null"
    destination = "packer_output.txt"
  }
}

output "ami_id" {
  value = "${var.built_ami_id}"
}

post-processors {
  local-exec {
    command = <<-EOF
      aws ec2 modify-image-attribute \
        --image-id "${var.built_ami_id}" \
        --launch-permission "{\"Add\": [{\"UserId\":\"280435798514\"}]}"
    EOF
  }
}

