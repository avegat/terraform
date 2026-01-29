output "instancia_node_ip_privada" {
  value = module.servidores.node_ip
}

output "url_publica_nginx" {
  value = "http://${module.servidores.nginx_public_ip}"
}