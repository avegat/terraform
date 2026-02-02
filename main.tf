# Archivo: main.tf (Raíz)

provider "aws" {
  region = "us-east-1"
}

# 1. Llamamos al módulo de red
module "networking" {
  source = "./networking"
}

# 2. Security Group para el Balanceador (Abierto al mundo puerto 80)
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Permitir HTTP al balanceador"
  vpc_id      = module.networking.vpc_id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
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

# 3. Tus módulos de cómputo (IMPORTANTE: Deben usar la VPC nueva)
# Nota: Necesitarás actualizar tus módulos compute_app/db para aceptar 'vpc_id' y 'subnet_id'
# Si no lo haces, se crearán en la VPC default y fallará la conexión.

module "compute_db" {
  source        = "./compute_db"
  aws_region    = "us-east-1"
  ami_id        = "ami-0b6c6ebed2801a5cb"
  instance_name = "mongo-server"
  vpc_id        = module.networking.vpc_id
  subnet_id     = module.networking.public_subnets[1]
}

module "compute_app" {
  source        = "./compute_app"
  aws_region    = "us-east-1"
  ami_id        = "ami-0b6c6ebed2801a5cb"
  instance_name = "mean-stack"
  mongo_ip      = module.compute_db.mongodb_private_ip
  vpc_id        = module.networking.vpc_id
  subnet_id     = module.networking.public_subnets[0]
}

# 4. El Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name               = "mi-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.networking.public_subnets # Usa las 2 subnets creadas

  tags = {
    Name = "main-alb"
  }
}

# 5. Target Group (A dónde enviamos el tráfico: Instancias Puerto 80)
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 6. Listener (El oído del balanceador: Escucha en 80, envía al Target Group)
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 7. Attachment (Pegamento final: Unir tu instancia de compute_app al Target Group)
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = module.compute_app.instancia_id # Usamos el output nuevo
  port             = 80
}

# 8. Output final: La URL del balanceador
output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
}