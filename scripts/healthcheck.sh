#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_COMPOSE="/opt/homebrew/bin/docker-compose"

cd "$ROOT"

echo "== Docker =="
$DOCKER_COMPOSE ps

echo ""
echo "== Dashboard :9119 (demo sin login — expect 200) =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:9119/ || true

echo ""
echo "== Gateway API :8642/health (opcional — off hasta make setup con API_SERVER_KEY) =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" --max-time 4 http://localhost:8642/health || echo "no escucha (API server desactivado — no fatal)"

echo ""
echo "== Volume .env (API keys live here after make setup) =="
if [[ -f data/hermes/.env ]]; then
  echo "data/hermes/.env exists (keys configured)"
else
  echo "data/hermes/.env missing — run: make setup"
fi
