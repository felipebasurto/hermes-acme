#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_COMPOSE="/opt/homebrew/bin/docker-compose"

cd "$ROOT"

echo "== Docker =="
$DOCKER_COMPOSE ps

echo ""
echo "== Dashboard :9119 (expect 401 without auth or 200 with basic auth) =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" -u acme:changeme http://localhost:9119/ || true

echo ""
echo "== Gateway API :8642/health (if enabled) =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8642/health || true

echo ""
echo "== Volume .env (API keys live here after make setup) =="
if [[ -f data/hermes/.env ]]; then
  echo "data/hermes/.env exists (keys configured)"
else
  echo "data/hermes/.env missing — run: make setup"
fi
