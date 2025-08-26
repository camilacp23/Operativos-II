#!/bin/bash
# -----------------------------------------------------------
# 04-cloudflare-tiered-cache.sh
# Activa Smart Tiered Cache (reduce golpes a tu origen).
# -----------------------------------------------------------

set -e

# ========== CONFIGURA AQUÍ ==========
CF_TOKEN="wxFb1N8z_vpTPZXvCO-MrG2FL4Fa2Lf_l90RArz9"
CF_ZONE_NAME="sistemasoperativos.online"
# ====================================

auth_hdr=(-H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json")

CF_ZONE_ID=$(curl -s "${auth_hdr[@]}" \
  "https://api.cloudflare.com/client/v4/zones?name=${CF_ZONE_NAME}" \
  | jq -r '.result[0].id')

echo "[+] Activando Tiered Cache..."
curl -sX PATCH "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/cache/tiered_cache_smart_topology_enable" \
  "${auth_hdr[@]}" --data '{"value":"on"}' | jq .

echo "Tiered Cache activado."
