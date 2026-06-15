#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEED="$ROOT/seed"
DATA="$ROOT/data/hermes"

mkdir -p "$DATA"

# Copy seed files into the Hermes data volume. Never overwrite an existing .env
# (API keys are configured via `make setup` / `hermes setup --portal`).
rsync -a --exclude='.env' "$SEED/" "$DATA/"

echo "Seeded $DATA from $SEED (preserved existing .env if any)"
