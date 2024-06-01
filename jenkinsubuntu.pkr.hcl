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

  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }

  post-processor "shell-local" {
    inline = [
      "AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ':' -f 2)",
      "aws ec2 copy-image --source-image-id $AMI_ID --source-region us-east-1 --name \"Jenkins-AMI-Copy\" --region us-west-2",
      "aws ec2 copy-image --source-image-id $AMI_ID --source-region us-east-1 --name \"Jenkins-AMI-Copy\" --region eu-west-1",
      "aws ec2 modify-image-attribute --image-id $AMI_ID --launch-permission \"Add=[{UserId=123456789012}]\" --region us-east-1"
    ]
  }
}
