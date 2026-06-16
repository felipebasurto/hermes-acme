#!/usr/bin/env bash
# Spanish-visible-surface verification for Acme v5.
set -euo pipefail

BASE_URL="${ACME_GUI_URL:-http://localhost:8787}"
FAIL=0
COOKIE_JAR="$(mktemp)"
trap 'rm -f "$COOKIE_JAR"' EXIT

fail() {
  echo "FAIL $*"
  FAIL=1
}

pass() {
  echo "PASS $*"
}

check_contains() {
  local label="$1"
  local content="$2"
  local pattern="$3"
  if grep -iE "$pattern" >/dev/null 2>&1 <<<"$content"; then
    pass "[$label] contiene: $pattern"
  else
    fail "[$label] falta: $pattern"
  fi
}

check_absent() {
  local label="$1"
  local content="$2"
  local pattern="$3"
  if grep -iE "$pattern" >/dev/null 2>&1 <<<"$content"; then
    fail "[$label] inglés visible detectado: $pattern"
    grep -oiE "$pattern" <<<"$content" | sort -u | head -8
  else
    pass "[$label] sin inglés visible: $pattern"
  fi
}

echo "== Spanish verify @ ${BASE_URL} =="

LOGIN_HTML=$(curl -sf --max-time 10 "${BASE_URL}/login" || { echo "FAIL fetch login"; exit 1; })
check_contains "login" "$LOGIN_HTML" 'Acceso al asistente de ofertas'
check_contains "login" "$LOGIN_HTML" 'Usuario'
check_contains "login" "$LOGIN_HTML" 'Contraseña demo'
check_absent "login" "$LOGIN_HTML" 'Sign in|Enter your password|Invalid password|Connection failed'

LOGIN_BODY=$(curl -sf --max-time 10 -c "$COOKIE_JAR" \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"acme-admin-demo"}' \
  "${BASE_URL}/api/auth/login" || true)
if grep -q '"role"[[:space:]]*:[[:space:]]*"admin"' <<<"$LOGIN_BODY"; then
  pass "[auth] login admin correcto"
else
  fail "[auth] login admin falló"
  echo "$LOGIN_BODY"
fi

HTML=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/" || { echo "FAIL fetch index"; exit 1; })
check_contains "index" "$HTML" 'Acme Maquinaria Especial'
check_contains "index" "$HTML" 'Conversación'
check_contains "index" "$HTML" 'Documentación'
check_contains "index" "$HTML" 'Procedimientos'
check_contains "index" "$HTML" 'Configuración'
check_contains "index" "$HTML" 'Escribe tu consulta de oferta'
check_absent "index" "$HTML" 'Welcome to|Message Hermes|Filter conversations|New conversation|Search skills'

I18N=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/i18n.js" || { echo "FAIL fetch i18n"; exit 1; })
check_contains "i18n" "$I18N" "tab_chat: 'Conversación'"
check_contains "i18n" "$I18N" "tab_settings: 'Configuración'"
check_contains "i18n" "$I18N" "providers_section_title: 'Proveedor de modelo'"
check_contains "i18n" "$I18N" "Documentación Acme"
check_absent "i18n-acme-overrides" "$(echo "$I18N" | sed -n '/Acme v5 Spanish industrial copy overrides/,$p')" 'TODO: translate|Session Toolsets|Welcome to Hermes Web UI|Search known tools across'

PANELS=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/panels.js" || { echo "FAIL fetch panels"; exit 1; })
check_contains "panels" "$PANELS" 'Acceso reservado a administrador'
check_contains "panels" "$PANELS" 'Documentación Acme — solo lectura'
check_absent "panels" "$PANELS" 'Hermes Web UI|Hermes Control Center|Open WebUI'

BOOT=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/boot.js" || { echo "FAIL fetch boot"; exit 1; })
check_contains "boot" "$BOOT" 'Acme Industrial'
check_contains "boot" "$BOOT" "skin:'acme-industrial'"
check_absent "boot" "$BOOT" "Message '\\+name"

if [[ "$FAIL" -eq 0 ]]; then
  echo "== ALL PASS =="
  exit 0
fi

echo "== FAILURES DETECTED =="
exit 1
