# Archivo: ./outputs.tf

output "node_ip_privada" {
  description = "IP privada para uso interno"
  # Referenciamos al módulo 'servidores' y su nuevo output
  value       = module.servidores.instancia_ip_privada
}

output "url_publica_nginx" {
  description = "URL para acceder a la web"
  # Aquí estaba el error. Ahora usamos el nombre correcto:
  value       = "http://${module.servidores.instancia_ip_publica}"
}