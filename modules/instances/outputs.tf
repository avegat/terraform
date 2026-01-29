output "node_ip" {
  description = "La dirección IP privada de la instancia de Node.js"
  value       = aws_instance.node_app.private_ip
}

output "nginx_public_ip" {
  description = "La IP pública para acceder a tu web"
  value       = aws_instance.nginx_proxy.public_ip
}