#!/usr/bin/env bash
# White-label verification for acme-webui served HTML/JS/assets.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_URL="${ACME_GUI_URL:-http://localhost:8787}"
FAIL=0
COOKIE_JAR="$(mktemp)"
trap 'rm -f "$COOKIE_JAR"' EXIT

check_forbidden() {
  local label="$1"
  local content="$2"
  local pattern="$3"
  if echo "$content" | grep -iE "$pattern" >/dev/null 2>&1; then
    echo "FAIL [$label] forbidden match: $pattern"
    echo "$content" | grep -oiE "$pattern" | sort -u | head -5
    FAIL=1
  else
    echo "PASS [$label] no forbidden: $pattern"
  fi
}

echo "== Branding verify @ ${BASE_URL} =="

LOGIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${BASE_URL}/login" || true)
if [[ "$LOGIN_STATUS" = "200" ]]; then
  echo "PASS [login] login page reachable"
else
  echo "FAIL [login] expected 200, got ${LOGIN_STATUS:-curl-error}"
  exit 1
fi

LOGIN_BODY=$(curl -sf --max-time 10 -c "$COOKIE_JAR" \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"acme-admin-demo"}' \
  "${BASE_URL}/api/auth/login" || true)
if echo "$LOGIN_BODY" | grep -q '"role"[[:space:]]*:[[:space:]]*"admin"'; then
  echo "PASS [auth] admin login role=admin"
else
  echo "FAIL [auth] admin login did not return role=admin"
  echo "$LOGIN_BODY"
  exit 1
fi

HTML=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/" || { echo "FAIL fetch index"; exit 1; })
check_forbidden "index.html" "$HTML" 'hermes web|hermes control|open webui|nousresearch|nous research'
check_forbidden "index.html-title" "$HTML" '<title>[^<]*(hermes|nous|open webui)'

if curl -sf --max-time 10 "${BASE_URL}/" | grep -i 'title>Acme' >/dev/null 2>&1; then
  echo "PASS [index.html] Acme title present"
else
  echo "FAIL [index.html] Acme title missing"
  FAIL=1
fi

if echo "$HTML" | grep -q 'acme-industrial.css'; then
  echo "PASS [index.html] industrial stylesheet referenced"
else
  echo "FAIL [index.html] industrial stylesheet missing"
  FAIL=1
fi

STATUS=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/api/auth/status" || echo "")
if echo "$STATUS" | grep -q '"acme_role"[[:space:]]*:[[:space:]]*"admin"'; then
  echo "PASS [auth/status] Acme admin role present"
else
  echo "FAIL [auth/status] Acme admin role missing"
  echo "$STATUS"
  FAIL=1
fi

MANIFEST=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/manifest.json" || echo "")
if [[ -n "$MANIFEST" ]]; then
  check_forbidden "manifest.json" "$MANIFEST" 'hermes|nous|open webui'
  if echo "$MANIFEST" | grep -i 'Acme' >/dev/null 2>&1; then
    echo "PASS [manifest.json] Acme name present"
  else
    echo "FAIL [manifest.json] Acme name missing"
    FAIL=1
  fi
fi

FAV=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/favicon.svg" || echo "")
if echo "$FAV" | grep -i 'ACME' >/dev/null 2>&1; then
  echo "PASS [favicon.svg] Acme logo marker present"
else
  echo "FAIL [favicon.svg] Acme logo marker missing"
  FAIL=1
fi

for js in ui.js panels.js boot.js; do
  JS=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/${js}" || echo "")
  [[ -z "$JS" ]] && continue
  check_forbidden "$js" "$JS" 'nousresearch|nous research|hermes web ui|hermes control center|open webui'
done

CSS=$(curl -sf --max-time 10 -b "$COOKIE_JAR" "${BASE_URL}/static/acme-industrial.css" || echo "")
if echo "$CSS" | grep -q -- '--acme-bg: #1a1f26'; then
  echo "PASS [acme-industrial.css] Acme steel token present"
else
  echo "FAIL [acme-industrial.css] Acme steel token missing"
  FAIL=1
fi

if [[ "$FAIL" -eq 0 ]]; then
  echo "== ALL PASS =="
  exit 0
fi
echo "== FAILURES DETECTED =="
exit 1
