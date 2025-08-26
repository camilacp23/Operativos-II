#!/usr/bin/env bash
set -euo pipefail
mkdir -p haproxy/certs
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout haproxy/certs/selfsigned.key \
  -out haproxy/certs/selfsigned.crt \
  -subj "/CN=localhost"
cat haproxy/certs/selfsigned.crt haproxy/certs/selfsigned.key > haproxy/certs/selfsigned.pem
echo "Certificado autofirmado generado en haproxy/certs/selfsigned.pem"
