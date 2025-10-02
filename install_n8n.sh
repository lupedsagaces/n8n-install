#!/bin/bash
set -e

# ==========================================
# Instalação automatizada do n8n com Docker
# e proxy reverso Nginx + Let's Encrypt
# ==========================================

INSTALL_DIR=~/n8n
DOMAIN="seudominio.com.br"
EMAIL="seuemail@gmail.com"  # troque pelo email para certbot

echo "[+] Atualizando pacotes..."
sudo apt update -y
sudo apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx

echo "[+] Criando diretório do n8n em $INSTALL_DIR..."
mkdir -p $INSTALL_DIR/n8n_data
cd $INSTALL_DIR

echo "[+] Ajustando permissões..."
sudo chown -R 1000:1000 n8n_data

echo "[+] Gerando docker-compose.yml..."
cat > docker-compose.yml << EOF
version: "3"

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=senhaforte123
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - DB_SQLITE_POOL_SIZE=5
      - N8N_RUNNERS_ENABLED=true
      - N8N_BLOCK_ENV_ACCESS_IN_NODE=false
      - N8N_GIT_NODE_DISABLE_BARE_REPOS=true
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=https://$DOMAIN/
      - N8N_SECURE_COOKIE=false
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

echo "[+] Criando configuração do Nginx..."
sudo tee /etc/nginx/sites-available/n8n > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN;

    # redireciona HTTP para HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_redirect http://localhost:5678/ https://$DOMAIN/;
    }
}
EOF

echo "[+] Ativando site no Nginx..."
sudo ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo "[+] Subindo containers n8n..."
sudo docker-compose pull
sudo docker-compose up -d

echo "[+] Gerando certificado SSL com Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

echo "[✓] Instalação concluída!"
echo "Acesse: https://$DOMAIN"
echo "Usuário: admin"
echo "Senha: senhaforte123"
