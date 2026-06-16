#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DC="${DOCKER_COMPOSE:-docker compose}"

cd "$ROOT"

echo "== Contenedores =="
$DC ps

echo ""
echo "== GUI Acme :3000 (Open WebUI, demo sin login — expect 200) =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" --max-time 6 http://localhost:3000/ || true

echo ""
echo "== Agente API OpenAI-compatible :8642/v1/models =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" --max-time 6 \
  -H "Authorization: Bearer ${API_SERVER_KEY:-acme-demo-local-key}" \
  http://localhost:8642/v1/models || echo "no escucha (revisar acme-agent)"

echo ""
echo "== Volumen .env (API keys del modelo tras make setup) =="
if [[ -f data/hermes/.env ]]; then
  echo "data/hermes/.env existe (modelo configurado)"
else
  echo "data/hermes/.env ausente — ejecutar: make setup (el chat queda en 'setup required' hasta entonces)"
fi

echo ""
echo "== Skills Acme en el volumen =="
ls data/hermes/skills/ 2>/dev/null || echo "(volumen sin sembrar — ejecutar make up)"
