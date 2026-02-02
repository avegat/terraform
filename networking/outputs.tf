# Archivo: networking/outputs.tf

output "vpc_id" {
  # El nombre del recurso en main.tf es "main_vpc"
  value = aws_vpc.main_vpc.id 
}

output "public_subnets" {
  # Los nombres en main.tf son "public_a" y "public_b"
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}