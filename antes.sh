#!/bin/bash
# -----------------------------------------------------------
# antes.sh
# Instala jq (para parsear JSON) y acme.sh (para certificados)
# -----------------------------------------------------------

set -e

# (1) jq y curl
if ! command -v jq >/dev/null 2>&1; then
  echo "[+] Instalando jq..."
  sudo apt-get update && sudo apt-get install -y jq
else
  echo "[=] jq ya instalado."
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "[+] Instalando curl..."
  sudo apt-get update && sudo apt-get install -y curl
else
  echo "[=] curl ya instalado."
fi

# (2) acme.sh para emitir certificados Let's Encrypt (DNS-01)
if [ ! -d "$HOME/.acme.sh" ]; then
  echo "[+] Instalando acme.sh..."
  curl https://get.acme.sh | sh
else
  echo "[=] acme.sh ya instalado."
fi

echo "Prerrequisitos listos."
