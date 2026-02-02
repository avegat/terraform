#!/bin/bash

# 1. Esperar a que el sistema termine sus actualizaciones automáticas (Evita error de bloqueo de apt)
echo "Esperando a que se libere el bloqueo de apt..."
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
   sleep 5
done
while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
   sleep 5
done

# 2. Actualizar e instalar TODO de una vez (Docker y Nginx)
# Al instalarlos juntos reducimos la probabilidad de fallos
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io nginx

# 3. Configurar Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
#
# 4. Crear archivo .env
cat <<EOF > /home/ubuntu/.env
PORT=3000
MONGOCONN=mongodb://admin:pass@${mongodb_ip}/unir?authSource=admin
NODE_ENV=production
EOF
chown ubuntu:ubuntu /home/ubuntu/.env

echo less /home/ubuntu/.env

# 5. Desplegar Contenedor Node.js
docker pull avegat92/nodejs-database:1.0.0
docker stop node-app || true
docker rm node-app || true

docker run -d \
  --name node-app \
  --restart always \
  -p 3000:3000 \
  --env-file /home/ubuntu/.env \
  avegat92/nodejs-database:1.0.0

# 6. Configurar Nginx
# IMPORTANTE: Usamos 'EOT' (con comillas simples) para que Bash 
# NO intente reemplazar las variables $host, $http_upgrade, etc.
cat <<'EOT' > /etc/nginx/sites-available/default
server {
    listen 80;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOT

# 7. Validar y Reiniciar Nginx
nginx -t # Verifica que la sintaxis sea correcta antes de reiniciar
systemctl restart nginx