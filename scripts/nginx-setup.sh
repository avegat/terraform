#!/bin/bash
apt-get update -y
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    location / {
        proxy_pass http://${node_ip}:3000;
    }
}
EOF

systemctl restart nginx