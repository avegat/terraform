#!/bin/bash
# 1. Instalación compatible con Ubuntu 🐧
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io

# Iniciar y habilitar Docker
systemctl start docker
systemctl enable docker

# 2. Permisos para el usuario ubuntu (en lugar de ec2-user)
usermod -aG docker ubuntu

# 3. Crear el archivo de ambiente en el home correcto 📄
# Usamos el path de ubuntu
cat <<EOF > /home/ubuntu/.env
PORT=3000
NODE_ENV=production
EOF

# Asegurar que el archivo pertenece al usuario ubuntu
chown ubuntu:ubuntu /home/ubuntu/.env

# 4. Descargar y correr la imagen REAL 🐳
# En scripts de user_data, docker corre como root, así que no hay problema de permisos aquí
docker pull avegat92/unir-js-demo:0.0.1

# Detener cualquier contenedor previo si existe para evitar conflictos
docker stop node-app || true
docker rm node-app || true

# Correr el contenedor
docker run -d \
  --name node-app \
  -p 3000:3000 \
  --env-file /home/ubuntu/.env \
  avegat92/unir-js-demo:0.0.1