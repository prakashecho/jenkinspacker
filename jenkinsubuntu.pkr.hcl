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

launch_block_device_mappings = [
  {
    device_name = "/dev/sda1"
    volume_size = 8
    volume_type = "gp2"
    encrypted   = true
    kms_key_id  = "22ad3ccd-28a1-4d05-ad73-5f284cea93b3"
  }
]

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

  post-processor "amazon-ami-copy" {
    ami_users    = ["280435798514"]
    encrypt_boot = true
    role_name    = "arn:aws:iam::874599947932:role/gitaws"
  }
}

