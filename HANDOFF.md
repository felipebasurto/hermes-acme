# Handoff — Acme Hermes reference deployment

## Repo

- **Path:** `~/code/hermes-acme`
- **Remote:** https://github.com/felipebasurto/hermes-acme
- **Purpose:** Runnable white-label Hermes demo for fictional Acme Maquinaria Especial (RFQ → borrador oferta)

## What was built

- Docker Compose single service (`acme-hermes`) with ports 8642/9119
- Makefile using `/opt/homebrew/bin/docker-compose` (not `docker compose`)
- Seed pack: SOUL, AGENTS, config, memory, theme, 3 skills
- Company corpus: 14 files Spanish fictional data, hero AC-2024-017
- Ops docs: RUNBOOK, ARCHITECTURE, CLIENT-PACK, VERIFICATION, DEMO-SCRIPTS

## Operator next steps

1. `cd ~/code/hermes-acme && make up`
2. `make setup` or `make setup-portal` (user action — no keys in git)
3. `make health`
4. Run Demo Script C in DEMO-SCRIPTS.md
5. Update VERIFICATION.md evidence table
6. `git push origin main` when ready to publish empty GitHub repo

## Known constraints

- Chat quality depends on model chosen in setup wizard
- `docker compose` (v2 plugin) intentionally not used — Mac uses v1 binary path
- All company names and figures are fictional

## Files not in git

- `data/hermes/.env` — API keys
- `data/hermes/sessions/` — runtime sessions

## Support contacts (real)

Maintainer: see GitHub repo owner.  
Hermes upstream: https://github.com/NousResearch/hermes-agent/issues

## Anti-patterns avoided

- No API keys in repo or seed
- No Hermes fork
- No auto-send to clients (forbidden in AGENTS.md + SOUL.md)
