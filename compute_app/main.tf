# --- GRUPO DE SEGURIDAD UNIFICADO ---

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for Nginx and Nodejs on same machine"

  # Entrada HTTP (Nginx) - Abierto al mundo
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Entrada SSH - Abierto (puedes restringir la IP si quieres seguridad extra)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida - Permitir todo (necesario para descargar paquetes/updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = var.vpc_id
}

# --- INSTANCIA UNICA ---

resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true 

  # LLAMAMOS A UN SCRIPT UNIFICADO
  # Ya no pasamos la variable node_ip, porque ahora es localhost
  user_data = templatefile("${path.root}/scripts/nodejs-nginx-setup.sh", {
     mongodb_ip = "${var.mongo_ip}"
  })
  subnet_id = var.subnet_id
  tags = { Name = "${var.instance_name}-fullstack" }
}