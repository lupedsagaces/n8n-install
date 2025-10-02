#!/bin/bash
# Script de instalação e configuração do n8n via Docker
# Autor: GoLab Offensive Security
# Uso: ./install_n8n.sh

set -e

# Variáveis de configuração
N8N_USER="admin"
N8N_PASS="minha_senha_forte"   # altere aqui sua senha
N8N_PORT=5678
INSTALL_DIR="$HOME/n8n"

echo -e "\n--- Atualizando sistema ---"
sudo apt update && sudo apt upgrade -y

echo -e "\n--- Instalando Docker e Docker Compose ---"
sudo apt install -y docker.io docker-compose

echo -e "\n--- Habilitando Docker ---"
sudo systemctl enable docker --now

echo -e "\n--- Criando diretório do n8n ---"
mkdir -p $INSTALL_DIR && cd $INSTALL_DIR

echo -e "\n--- Criando arquivo docker-compose.yml ---"
cat > docker-compose.yml <<EOF
version: "3"

services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "${N8N_PORT}:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASS}
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

echo -e "\n--- Subindo container do n8n ---"
sudo docker-compose up -d

echo -e "\n✅ Instalação concluída!"
echo -e "Acesse seu n8n em: http://$(curl -s ifconfig.me):${N8N_PORT}"
echo -e "Usuário: ${N8N_USER}"
echo -e "Senha: ${N8N_PASS}"
