packer {
  required_plugins {
    amazon = {
      version = ">=1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  access_key    = "AKIA4XIRYD2OLA3VD6DW"
  secret_key    = "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"
  ami_name      = "Jenkinss"
  instance_type = "t2.small"
  region        = "us-east-2"
  source_ami    = "ami-09040d770ffe2224f"
  ssh_username  = "ubuntu"
}

build {
  name    = "jenkinss"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install openjdk-11-jdk -y",
      "sudo apt install maven wget unzip -y",
      "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install jenkins -y",
      "sudo ufw enable ",
      "sudo ufw allow 8080/tcp"
      
    ]
  }


}
