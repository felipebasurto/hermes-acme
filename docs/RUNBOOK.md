# Runbook — Acme Hermes demo

## Prerequisites

- Docker Desktop (or Docker Engine) running
- `docker-compose` v1 at `/opt/homebrew/bin/docker-compose` (Makefile uses this path)
- Ports **8642** and **9119** free on host

## Seguridad del panel (demo vs producción)

La demo arranca el dashboard **sin login** (`HERMES_DASHBOARD_INSECURE=1` en `docker-compose.yml`). El gate de auth de Hermes solo se activa si se registra un proveedor (p.ej. `HERMES_DASHBOARD_BASIC_AUTH_*`); al no registrar ninguno y bindear a `0.0.0.0`, Hermes exige `--insecure` o falla cerrado. Esto es aceptable **solo en LAN/host de confianza**.

**En producción**, NO expongas `:9119` con `INSECURE`. Pon el panel detrás de uno de:

- VPN (WireGuard/Tailscale) y bind a interfaz privada, o
- Reverse proxy con TLS + auth (Caddy/nginx con basic_auth o SSO), o
- El proveedor OAuth/OIDC de Hermes (`HERMES_DASHBOARD_OAUTH_CLIENT_ID` / `HERMES_DASHBOARD_OIDC_*`), quitando `HERMES_DASHBOARD_INSECURE`.

## First boot

```bash
cd ~/code/hermes-acme
make up
make setup        # interactive — writes ./data/hermes/.env
make health
```

Dashboard: http://localhost:9119 (demo sin login)

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
| Dashboard pide login | No debería en demo. Confirma `HERMES_DASHBOARD_INSECURE=1` y que NO hay `HERMES_DASHBOARD_BASIC_AUTH_*` en el compose; reinicia con `make down && make up` |
| Chat: "Setup Required / model provider" | Ejecuta `make setup`; confirma que existe `data/hermes/.env` con la key |
| Aparecen ~73 skills genéricos | Falta el marcador. Confirma `data/hermes/.no-bundled-skills` (se siembra desde `seed/`); en volumen ya poblado: `make down && rm -rf data/hermes && make up` |
| Logo/marca Acme no aparece | El logo se sirve por `/dashboard-plugins/acme-admin/dist/logo.svg`; confirma que el plugin se descubrió (`curl :9119/api/dashboard/plugins`) y recarga |
| Pestañas/temas Nous visibles | El tema `acme` debe estar activo (`curl :9119/api/dashboard/themes` → `active: acme`); el ocultado usa el `customCSS` del tema |
| Port in use | Cambia los puertos host en `docker-compose.yml` o libera 8642/9119 |
| Company docs not found | Volumen `./seed/company-docs:/workspace/docs:ro` — revisa el mount en `docker compose ps` |

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
