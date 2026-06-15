# Runbook — Acme Hermes demo

## Prerequisites

- Docker Desktop (or Docker Engine) running
- `docker-compose` v1 at `/opt/homebrew/bin/docker-compose` (Makefile uses this path)
- Ports **8642** and **9119** free on host

## First boot

```bash
cd ~/code/hermes-acme
make up
make setup        # interactive — writes ./data/hermes/.env
make health
```

Dashboard: http://localhost:9119 (`acme` / `changeme`)

## Configure model (once)

| Command | When |
|---------|------|
| `make setup` | Paste API key in Hermes wizard |
| `make setup-portal` | Nous Portal OAuth one-shot |

Keys are stored **only** in `./data/hermes/.env`. Re-run setup to rotate keys.

## Reseed after git pull

```bash
make seed
make up
```

`seed-volume.sh` uses `rsync` and **never overwrites** an existing `.env`.

## Logs and shell

```bash
make logs
make shell      # bash inside acme-hermes container
```

## Stop

```bash
make down
```

## Troubleshooting

| Symptom | Action |
|---------|--------|
| Dashboard 401 | Expected without auth; use `-u acme:changeme` or browser prompt |
| Chat errors / no model | Run `make setup`; confirm `data/hermes/.env` exists |
| Port in use | Change host ports in `docker-compose.yml` or free 8642/9119 |
| Theme not visible | Confirm `seed/config.yaml` has `dashboard.theme: acme` and run `make seed` |
| Company docs not found | Volume `./seed/company-docs:/workspace/docs:ro` — check mount in `docker compose ps` |

## Security (demo)

- Change basic auth password before any non-local exposure.
- Do not commit `data/hermes/.env` or session exports.
- Corpus is fictional; no PII real.

## Backup

To preserve a working demo state:

```bash
tar czf acme-hermes-backup.tgz data/hermes/
```

Exclude from shared backups if `.env` contains production-like keys.
