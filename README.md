# Acme Hermes — reference deployment

White-labeled [Hermes Agent](https://github.com/NousResearch/hermes-agent) (MIT) for **Acme Maquinaria Especial S.L.** — RFQ → borrador oferta técnica.

Fictional Burgos industrial client. **No API keys in this repo.**

## Quick start (3 steps)

```bash
cd ~/code/hermes-acme
make up          # seed volume + start gateway + dashboard
make setup       # once: Hermes wizard — API key / Nous Portal OAuth → data/hermes/.env
```

Open dashboard: http://localhost:9119 — user `acme`, password `changeme`.

**API keys live only in `./data/hermes/.env`**, created when you run `make setup`. They are never committed.

Optional OAuth (recommended by Hermes docs):

```bash
make setup-portal
```

Smoke check:

```bash
make health
```

## Demo

Paste the RFQ from `seed/company-docs/rfq/ejemplo-entrada-001.txt` into dashboard chat (after setup).

## Layout

| Path | Purpose |
|------|---------|
| `seed/` | SOUL, AGENTS, skills, theme, config (versioned) |
| `seed/company-docs/` | Fictional corpus (mounted read-only at `/workspace/docs`) |
| `data/hermes/` | Runtime volume (gitignored `.env` and `sessions/`) |
| `docker-compose.yml` | `nousresearch/hermes-agent` service |
| `scripts/` | Seed and health helpers |

## Make targets

- `make seed` — copy `seed/` → `data/hermes/` (preserves existing `.env`)
- `make up` / `make down` — start/stop stack
- `make setup` / `make setup-portal` — configure model credentials
- `make logs` / `make health` / `make shell`

## Docs

- [docs/RUNBOOK.md](docs/RUNBOOK.md) — operations
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — components
- [docs/CLIENT-PACK.md](docs/CLIENT-PACK.md) — what ships to a client
- [DEMO-SCRIPTS.md](DEMO-SCRIPTS.md) — demo script
- [VERIFICATION.md](VERIFICATION.md) — smoke checklist
- [HANDOFF.md](HANDOFF.md) — agent handoff notes
