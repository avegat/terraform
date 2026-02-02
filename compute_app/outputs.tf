# Archivo: modules/instances/outputs.tf

# 1. Exportamos la IP Pública
output "instancia_ip_publica" {
  description = "IP publica de la maquina unificada"
  # Asegúrate que 'web_server' es el nombre del resource en modules/instances/main.tf
  value       = aws_instance.web_server.public_ip
}

# 2. Exportamos la IP Privada
output "instancia_ip_privada" {
  description = "IP privada de la maquina unificada"
  value       = aws_instance.web_server.private_ip
}

output "instancia_id" {
  description = "ID de la instancia EC2 para adjuntar al Target Group"
  value       = aws_instance.web_server.id
}