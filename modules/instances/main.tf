# --- GRUPOS DE SEGURIDAD ---

resource "aws_security_group" "nginx_sg" {
  name = "nginx_sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "node_sg" {
  name = "node_sg"
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id] 
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- INSTANCIAS ---


resource "aws_instance" "node_app" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.node_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true 

  user_data = templatefile("${path.root}/scripts/node-image-pull.sh", {})

  tags = { Name = "${var.instance_name}-node" }
}

resource "aws_instance" "nginx_proxy" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true 

  user_data = templatefile("${path.root}/scripts/nginx-setup.sh", {
    node_ip = aws_instance.node_app.private_ip
  })

  tags = { Name = "${var.instance_name}-nginx" }
}