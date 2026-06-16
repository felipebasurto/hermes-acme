#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEED="$ROOT/seed"
DATA="$ROOT/data/hermes"
COMPOSE_KEY="${API_SERVER_KEY:-acme-demo-local-key}"

mkdir -p "$DATA/webui"

# Copy seed files into the Hermes data volume. Never overwrite an existing .env
# (API keys are configured via `make setup` / `hermes setup --portal`).
rsync -a --exclude='.env' --exclude='company-docs/' "$SEED/" "$DATA/"

# Keep internal LAN token aligned between compose and persisted agent config.
ENV_FILE="$DATA/.env"
touch "$ENV_FILE"
if grep -q '^API_SERVER_KEY=' "$ENV_FILE" 2>/dev/null; then
  sed -i.bak "s/^API_SERVER_KEY=.*/API_SERVER_KEY=${COMPOSE_KEY}/" "$ENV_FILE"
  rm -f "${ENV_FILE}.bak"
else
  echo "API_SERVER_KEY=${COMPOSE_KEY}" >> "$ENV_FILE"
fi

echo "Seeded $DATA from $SEED (preserved model keys in .env; synced API_SERVER_KEY)"
