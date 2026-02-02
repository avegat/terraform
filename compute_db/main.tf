provider "aws" {
  region = var.aws_region
}

# 1. NUEVO: Creamos un Security Group específico para la Base de Datos
resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-security-group"
  description = "Permitir acceso a Mongo interno"
  vpc_id      = var.vpc_id  # <--- Aquí usamos la variable vpc_id que agregamos

  # Regla de entrada: Permitir tráfico al puerto 27017 (Mongo)
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Idealmente, aquí podrías restringirlo a la subnet de la APP
    # cidr_blocks = ["10.0.0.0/16"] # Más seguro: solo tráfico interno de la VPC
  }

  # Regla de salida: Permitir todo (para que Docker pueda descargar imágenes)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongodb" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  # 2. NUEVO: Asignamos la instancia a la Subnet correcta y le pegamos el Security Group
  subnet_id              = var.subnet_id 
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]

  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
    #!/bin/bash
    # Nota: He quitado 'yum' porque esa AMI parece ser Ubuntu (apt)
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce

    systemctl start docker
    systemctl enable docker

    # Ejecutamos Mongo exponiendo el puerto 27017
    docker run -d --name mongodb-6 -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=m1Pa55 -v mongo_data:/data/db mongo:6.0
  EOF
}