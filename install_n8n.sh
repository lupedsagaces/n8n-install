#!/bin/bash
set -e

# Diretório de instalação
INSTALL_DIR=~/n8n

echo "[+] Criando diretório do n8n em $INSTALL_DIR..."
mkdir -p $INSTALL_DIR/n8n_data
cd $INSTALL_DIR

echo "[+] Ajustando permissões..."
sudo chown -R 1000:1000 n8n_data

echo "[+] Gerando docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
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
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

echo "[+] Subindo containers..."
sudo docker-compose pull
sudo docker-compose up -d

echo "[✓] n8n instalado e rodando em http://SEU_IP:5678"
echo "Usuário: admin"
echo "Senha: senhaforte123"
