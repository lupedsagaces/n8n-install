# n8n-install
## Ferramenta para automatizar a instalação do n8n no linux

É necessário ter um domínio https para que as integrações sejam feitas corretamente entre os nodes do n8n

Criei um direcionamento na minha vps para o noip, e dentro da vps usei o nginx com let's encrypt

### Como usar:

Clonar o projeto:

`git clone https://github.com/lupedsagaces/n8n-install.git`

Entrar no script e modificar a senha:

`nano install_n8n.sh`

Dar permissão:

`chmod +x install_n8n.sh`

Executar:

`./install_n8n.sh`
