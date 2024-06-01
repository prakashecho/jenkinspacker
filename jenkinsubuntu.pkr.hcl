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
  source_ami    = "ami-04b70fa74e45c3917"
  ssh_username  = "ubuntu"

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 8
    volume_type = "gp2"
    encrypted   = true
    kms_key_id  = "22ad3ccd-28a1-4d05-ad73-5f284cea93b3"
  }
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
      # Copy the AMI to another region
      ami_id=$(aws ec2 copy-image --source-image-id ${self.source_ami} --source-region us-east-1 --region us-west-1 --name Jenkins-AMI --output text --query "ImageId")

      # Share the copied AMI with another AWS account
      aws ec2 modify-image-attribute --image-id $ami_id --launch-permission "{\"Add\": [{\"UserId\":\"280435798514\"}]}"
    EOF
  }
}
