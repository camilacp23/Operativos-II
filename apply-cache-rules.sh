#!/bin/bash
# ============================================================
# apply-cache-rules.sh
# Aplica Cache Rules en Cloudflare (estáticos 7d + bypass cookies/admin)
# - Detecta ZONE_ID automáticamente
# - Crea entrypoint si no existe
# - Sube reglas y resume resultado
# Requisitos: bash, curl, jq, API Token con permisos:
#   Zone:Read, DNS:Edit (no imprescindible aquí), Settings:Edit, Rulesets(Edit)
# Uso:
#   export CF_TOKEN="TU_API_TOKEN"
#   ./apply-cache-rules.sh sistemasoperativos.online
# ============================================================

set -euo pipefail

# --------- Inputs ----------
if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <dominio>"
  echo "Ej:  $0 sistemasoperativos.online"
  exit 1
fi
CF_ZONE_NAME="$1"

if [[ -z "${CF_TOKEN:-}" ]]; then
  echo "ERROR: Debes exportar CF_TOKEN en el entorno."
  echo "Ej: export CF_TOKEN='xxxxxxxxxxxxxxxxxxxxxxxx'"
  exit 1
fi

# --------- Checks ----------
command -v jq >/dev/null || { echo "ERROR: falta 'jq' (sudo apt-get install -y jq)"; exit 1; }
command -v curl >/dev/null || { echo "ERROR: falta 'curl'"; exit 1; }

AUTH=(-H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json")

# --------- Zona ----------
echo "[+] Resolviendo Zone ID para: $CF_ZONE_NAME"
CF_ZONE_ID=$(curl -s "${AUTH[@]}" \
  "https://api.cloudflare.com/client/v4/zones?name=${CF_ZONE_NAME}" \
  | jq -r '.result[0].id // empty')

if [[ -z "$CF_ZONE_ID" ]]; then
  echo "ERROR: No se encontró la zona '$CF_ZONE_NAME' con este token. Verifica permisos y nombre."
  exit 1
fi
echo "[=] ZONE_ID: $CF_ZONE_ID"

# --------- EntryPoint (ruleset) ----------
echo "[+] Consultando entrypoint de 'http_request_cache_settings'..."
ENTRY_JSON=$(curl -s "${AUTH[@]}" \
  "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/rulesets/phases/http_request_cache_settings/entrypoint")

ENTRY_ID=$(echo "$ENTRY_JSON" | jq -r '.result.id // empty')

if [[ -z "$ENTRY_ID" ]]; then
  echo "[*] No existe entrypoint. Creándolo..."
  CREATE_JSON=$(curl -sX POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/rulesets" \
    "${AUTH[@]}" \
    --data '{"name":"cache-settings","kind":"zone","phase":"http_request_cache_settings","rules":[]}')
  ENTRY_ID=$(echo "$CREATE_JSON" | jq -r '.result.id // empty')
  if [[ -z "$ENTRY_ID" ]]; then
    echo "ERROR: No se pudo crear el ruleset de cache_settings."
    echo "$CREATE_JSON" | jq .
    exit 1
  fi
  echo "[=] ENTRYPOINT creado: $ENTRY_ID"
else
  echo "[=] ENTRYPOINT existente: $ENTRY_ID"
fi

# --------- Reglas ----------
echo "[+] Construyendo reglas..."
RULES_JSON=$(cat <<'EOF'
{
  "rules": [
    {
      "description": "Cache estaticos 7d",
      "expression": "(http.request.uri.path.extension in {\"css\" \"js\" \"jpg\" \"jpeg\" \"png\" \"webp\" \"svg\" \"gif\" \"ico\" \"woff\" \"woff2\"})",
      "action": "set_cache_settings",
      "action_parameters": {
        "cache": true,
        "edge_ttl": { "mode": "override_origin", "default": 604800 },
        "browser_ttl": { "mode": "respect_origin" }
      },
      "enabled": true
    },
    {
      "description": "Bypass usuarios logueados (WP/Drupal)",
      "expression": "(http.cookie contains \"wordpress_logged_in=\") or (http.cookie contains \"comment_author=\") or (http.cookie contains \"SESS\") or (http.cookie contains \"SSESS\")",
      "action": "set_cache_settings",
      "action_parameters": { "cache": false },
      "enabled": true
    },
    {
      "description": "Bypass zonas admin (WP/Drupal)",
      "expression": "(starts_with(http.request.uri.path, \"/wp-admin\")) or (http.request.uri.path eq \"/wp-login.php\") or (starts_with(http.request.uri.path, \"/user\")) or (starts_with(http.request.uri.path, \"/admin\"))",
      "action": "set_cache_settings",
      "action_parameters": { "cache": false },
      "enabled": true
    }
  ]
}
EOF
)

echo "[+] Publicando reglas en ruleset: $ENTRY_ID"
PUT_JSON=$(curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/rulesets/$ENTRY_ID" \
  "${AUTH[@]}" \
  --data "$RULES_JSON")

SUCCESS=$(echo "$PUT_JSON" | jq -r '.success // false')
if [[ "$SUCCESS" != "true" ]]; then
  echo "ERROR: Falló la publicación de reglas:"
  echo "$PUT_JSON" | jq .
  exit 1
fi

echo "[=] Reglas publicadas correctamente."

# --------- Resumen ----------
echo "[+] Resumen de reglas aplicadas:"
curl -s "${AUTH[@]}" \
  "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/rulesets/phases/http_request_cache_settings/entrypoint" \
| jq '.result.rules[] | {description, action, expression}'
echo "Listo."
