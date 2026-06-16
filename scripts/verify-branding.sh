#!/usr/bin/env bash
# White-label verification for acme-webui served HTML/JS/assets.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_URL="${ACME_GUI_URL:-http://localhost:8787}"
FAIL=0

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

HTML=$(curl -sf --max-time 10 "${BASE_URL}/" || { echo "FAIL fetch index"; exit 1; })
check_forbidden "index.html" "$HTML" 'hermes web|hermes control|open webui|nousresearch|nous research'
check_forbidden "index.html-title" "$HTML" '<title>[^<]*(hermes|nous|open webui)'

if curl -sf --max-time 10 "${BASE_URL}/" | grep -i 'title>Acme' >/dev/null 2>&1; then
  echo "PASS [index.html] Acme title present"
else
  echo "FAIL [index.html] Acme title missing"
  FAIL=1
fi

MANIFEST=$(curl -sf --max-time 10 "${BASE_URL}/static/manifest.json" || echo "")
if [[ -n "$MANIFEST" ]]; then
  check_forbidden "manifest.json" "$MANIFEST" 'hermes|nous|open webui'
  if echo "$MANIFEST" | grep -i 'Acme' >/dev/null 2>&1; then
    echo "PASS [manifest.json] Acme name present"
  else
    echo "FAIL [manifest.json] Acme name missing"
    FAIL=1
  fi
fi

FAV=$(curl -sf --max-time 10 "${BASE_URL}/static/favicon.svg" || echo "")
if echo "$FAV" | grep -i 'ACME' >/dev/null 2>&1; then
  echo "PASS [favicon.svg] Acme logo marker present"
else
  echo "FAIL [favicon.svg] Acme logo marker missing"
  FAIL=1
fi

for js in ui.js panels.js boot.js; do
  JS=$(curl -sf --max-time 10 "${BASE_URL}/static/${js}" || echo "")
  [[ -z "$JS" ]] && continue
  check_forbidden "$js" "$JS" 'nousresearch|nous research|hermes web ui|hermes control center|open webui'
done

if [[ "$FAIL" -eq 0 ]]; then
  echo "== ALL PASS =="
  exit 0
fi
echo "== FAILURES DETECTED =="
exit 1
