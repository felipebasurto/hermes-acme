#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DC="${DOCKER_COMPOSE:-docker compose}"

cd "$ROOT"

echo "== Contenedores =="
$DC ps

echo ""
echo "== GUI Acme :8787 (hermes-webui fork, demo sin password — expect 200) =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" --max-time 10 http://localhost:8787/ || true

echo ""
echo "== Agente API OpenAI-compatible :8642/v1/models =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" --max-time 6 \
  -H "Authorization: Bearer ${API_SERVER_KEY:-acme-demo-local-key}" \
  http://localhost:8642/v1/models || echo "no escucha (revisar acme-agent)"

echo ""
echo "== Volumen .env (API keys del modelo tras make setup) =="
if [[ -f data/hermes/.env ]] && grep -qE '^(OPENROUTER_API_KEY|OPENAI_API_KEY|ANTHROPIC_API_KEY)=' data/hermes/.env 2>/dev/null; then
  echo "data/hermes/.env tiene key de modelo configurada"
elif [[ -f data/hermes/.env ]]; then
  echo "data/hermes/.env existe (solo token interno — ejecutar make setup para LLM)"
else
  echo "data/hermes/.env ausente — ejecutar: make up && make setup"
fi

echo ""
echo "== Skills Acme en el volumen =="
ls data/hermes/skills/ 2>/dev/null || echo "(volumen sin sembrar — ejecutar make up)"
