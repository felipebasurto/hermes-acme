#!/usr/bin/env bash
# Idempotent Acme white-label patches for hermes-webui served assets.
# Usage: patch-webui-branding.sh <webui-root>
set -euo pipefail

ROOT="${1:?webui root required}"
ACME_LOGO="${ACME_LOGO:-}"
APP_NAME="Acme Maquinaria Especial"
PANEL_NAME="Panel Acme"
AGENT_LABEL="Asistente Acme"
BOT_DEFAULT="Asistente Acme"

patch_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  sed -i \
    -e "s/Hermes Web UI/${APP_NAME}/g" \
    -e "s/Hermes WebUI/${APP_NAME}/g" \
    -e "s/Hermes Web/${APP_NAME}/g" \
    -e "s/Hermes Control Center/${PANEL_NAME}/g" \
    -e "s/Hermes Dashboard/${PANEL_NAME}/g" \
    -e "s/Official Hermes Dashboard/${PANEL_NAME}/g" \
    -e "s/Hermes Agent/${AGENT_LABEL}/g" \
    -e "s/Hermes agent/${AGENT_LABEL}/g" \
    -e "s/Hermes is not responding/El asistente no responde/g" \
    -e "s/Hermes agent is not responding/El asistente no responde/g" \
    -e "s/Message Hermes…/Escribe tu mensaje…/g" \
    -e "s/Message Hermes\.\.\./Escribe tu mensaje…/g" \
    -e "s/Welcome to Hermes Web UI/Bienvenido a ${APP_NAME}/g" \
    -e "s/Hermes test/Acme test/g" \
    -e "s/Hermes caduceus/Acme logo/g" \
    -e "s/Hermes AI Agent Web UI/Asistente industrial Acme/g" \
    -e "s/Open Hermes ready for a new chat/Nueva conversación Acme/g" \
    -e "s/Stop the Hermes WebUI server/Detener servidor Acme/g" \
    -e "s/Hermes WebUI session/Acme session/g" \
    -e "s/Hermes requires a server connection/Se requiere conexión al servidor/g" \
    -e 's|https://hermes-agent\.nousresearch\.com[^"'\'' ]*|#|g' \
    -e 's|https://[^"'\'' ]*nousresearch\.com[^"'\'' ]*|#|g' \
    -e 's|nousresearch\.com|acme.local|g' \
    -e 's|Nous Research|Acme Maquinaria Especial|g' \
    -e 's|Nous Portal|Portal Acme|g' \
    "$f"
}

# HTML shell and PWA metadata
for f in \
  "$ROOT/static/index.html" \
  "$ROOT/static/manifest.json" \
  "$ROOT/static/sw.js" \
  "$ROOT/static/onboarding.js" \
  "$ROOT/static/panels.js" \
  "$ROOT/static/ui.js" \
  "$ROOT/static/sessions.js" \
  "$ROOT/static/messages.js" \
  "$ROOT/static/i18n.js" \
  "$ROOT/static/login.js" \
  "$ROOT/static/boot.js"
do
  patch_file "$f"
done

# Title and titlebar defaults in index.html
if [[ -f "$ROOT/static/index.html" ]]; then
  sed -i \
    -e "s/<title>Hermes<\/title>/<title>${APP_NAME}<\/title>/" \
    -e "s/content=\"Hermes\"/content=\"${APP_NAME}\"/g" \
    -e "s/>Hermes</>${APP_NAME}</g" \
    "$ROOT/static/index.html"
fi

# manifest.json names and Acme theme colors
if [[ -f "$ROOT/static/manifest.json" ]]; then
  sed -i \
    -e "s/\"name\": \"Hermes\"/\"name\": \"${APP_NAME}\"/" \
    -e "s/\"short_name\": \"Hermes\"/\"short_name\": \"Acme\"/" \
    -e 's/"background_color": "#0D0D1A"/"background_color": "#1a1f26"/' \
    -e 's/"theme_color": "#0D0D1A"/"theme_color": "#1a1f26"/' \
    "$ROOT/static/manifest.json"
fi

# JS default bot display name (preserve API identifiers)
for f in "$ROOT/static/ui.js" "$ROOT/static/panels.js"; do
  [[ -f "$f" ]] || continue
  sed -i \
    -e "s/window._botName||'Hermes'/window._botName||'${BOT_DEFAULT}'/g" \
    -e "s/bot_name||'Hermes'/bot_name||'${BOT_DEFAULT}'/g" \
    -e "s/settings.bot_name||'Hermes'/settings.bot_name||'${BOT_DEFAULT}'/g" \
    -e "s/botName||'Hermes'/botName||'${BOT_DEFAULT}'/g" \
    "$f"
done

# Server-side defaults for login and settings
for f in \
  "$ROOT/api/config.py" \
  "$ROOT/api/routes.py" \
  "$ROOT/api/onboarding.py" \
  "$ROOT/api/passkeys.py" \
  "$ROOT/api/models.py"
do
  [[ -f "$f" ]] || continue
  sed -i \
    -e "s/\"HERMES_WEBUI_BOT_NAME\", \"Hermes\"/\"HERMES_WEBUI_BOT_NAME\", \"${BOT_DEFAULT}\"/" \
    -e 's/_settings.get("bot_name") or "Hermes"/_settings.get("bot_name") or "'"${BOT_DEFAULT}"'"/g' \
    -e 's/body\["bot_name"\] = (str(body\["bot_name"\]) or "").strip() or "Hermes"/body["bot_name"] = (str(body["bot_name"]) or "").strip() or "'"${BOT_DEFAULT}"'"/g' \
    -e 's/settings.get("bot_name") or "Hermes"/settings.get("bot_name") or "'"${BOT_DEFAULT}"'"/g' \
    -e 's/_RP_NAME = "Hermes WebUI"/_RP_NAME = "'"${APP_NAME}"'"/' \
    -e 's/"name": "Hermes WebUI"/"name": "'"${APP_NAME}"'"/g' \
    -e "s/text == 'Hermes WebUI'/text == '${APP_NAME}'/" \
    -e "s/prefix = 'Hermes WebUI #'/prefix = '${APP_NAME} #'/" \
    "$f"
done

# sessions.js title detection
if [[ -f "$ROOT/static/sessions.js" ]]; then
  sed -i \
    -e "s/title==='Hermes WebUI'/title==='${APP_NAME}'/" \
    -e "s/^Hermes WebUI #/${APP_NAME} #/" \
    "$ROOT/static/sessions.js"
fi

# Replace favicons with Acme logo
if [[ -n "$ACME_LOGO" && -f "$ACME_LOGO" ]]; then
  cp "$ACME_LOGO" "$ROOT/static/favicon.svg"
  cp "$ACME_LOGO" "$ROOT/static/favicon-512.svg"
  if command -v rsvg-convert >/dev/null 2>&1; then
    for size in 32 192 512; do
      rsvg-convert -w "$size" -h "$size" "$ACME_LOGO" \
        -o "$ROOT/static/favicon-${size}.png"
    done
    rsvg-convert -w 180 -h 180 "$ACME_LOGO" \
      -o "$ROOT/static/apple-touch-icon.png"
  fi
fi

# Neutralize upstream "nous" skin and theme keys in served static assets
if [[ -f "$ROOT/static/style.css" ]]; then
  sed -i \
    -e 's/data-skin="nous"/data-skin="acme-industrial"/g' \
    -e 's/\[data-skin="nous"\]/[data-skin="acme-industrial"]/g' \
    -e 's/Nous Research/Acme Maquinaria Especial/g' \
    -e 's/Nous skin/Acme skin/g' \
    -e 's/Nous Portal/Portal Acme/g' \
    "$ROOT/static/style.css"
fi
if [[ -f "$ROOT/static/index.html" ]]; then
  sed -i \
    -e 's/nous:1/acme-industrial:1/g' \
    -e 's/data-skin="nous"/data-skin="acme-industrial"/g' \
    "$ROOT/static/index.html"
fi
if [[ -f "$ROOT/static/boot.js" ]]; then
  sed -i \
    -e "s/{name:'Nous'/{name:'Acme'/g" \
    -e 's/Nous setup/Acme setup/g' \
    "$ROOT/static/boot.js"
fi
if [[ -f "$ROOT/static/panels.js" ]]; then
  sed -i \
    -e 's/Nous setup/Acme setup/g' \
    -e 's/(Nous/(Acme/g' \
    "$ROOT/static/panels.js"
fi

# Build assert: forbidden vendor strings in served static tree (word-aware, not "synchronously")
nous_count=$( { grep -riE 'nousresearch|Nous Research|data-skin=.nous|\bnous:1|name:.?.Nous' "$ROOT/static/" 2>/dev/null || true; } | wc -l | tr -d ' ')
hermes_web=$( { grep -ri 'Hermes Web' "$ROOT/static/" 2>/dev/null || true; } | wc -l | tr -d ' ')
open_webui=$( { grep -ri 'Open WebUI' "$ROOT/static/" 2>/dev/null || true; } | wc -l | tr -d ' ')
echo "[patch-webui] static/ nous-brand hits: ${nous_count} (expect 0)"
echo "[patch-webui] static/ 'Hermes Web' hits: ${hermes_web} (expect 0)"
echo "[patch-webui] static/ Open WebUI hits: ${open_webui} (expect 0)"
[[ "$nous_count" = "0" ]] || { echo "[patch-webui] ERROR: nous brand remains in static/"; grep -riE 'nousresearch|Nous Research|data-skin=.nous|\bnous:1|name:.?.Nous' "$ROOT/static/" | head -20; exit 1; }
[[ "$hermes_web" = "0" ]] || { echo "[patch-webui] ERROR: Hermes Web remains in static/"; exit 1; }
[[ "$open_webui" = "0" ]] || { echo "[patch-webui] ERROR: Open WebUI remains in static/"; exit 1; }

echo "[patch-webui] branding patch complete"
