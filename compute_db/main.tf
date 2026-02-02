provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "mongodb" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce

    
    systemctl start docker
    systemctl enable docker

    docker run -d  --name mongodb-6 -p 27017:27017   -e MONGO_INITDB_ROOT_USERNAME=admin  -e MONGO_INITDB_ROOT_PASSWORD=m1Pa55  -v mongo_data:/data/db mongo:6.0

  EOF
}