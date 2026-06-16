# Runbook — Acme Agent v4

## Prerequisitos

- Docker Engine + Compose v2 (`docker compose`).
- Puertos libres: **8787** (GUI Acme) y **8642** (API agente, debug).

## Primer arranque

```bash
make build
make up
make setup        # interactivo — API key del modelo → data/hermes/.env
make health
./scripts/verify-branding.sh
```

GUI: **http://localhost:8787** (demo sin `HERMES_WEBUI_PASSWORD`).

## Two-container ops

| Contenedor | Rol | Volumen clave |
|------------|-----|---------------|
| `acme-agent` | Gateway Hermes | `./data/hermes` → `/opt/data`, `hermes-agent-src` → `/opt/hermes` |
| `acme-webui` | GUI agente | `./data/hermes` → `/home/hermeswebui/.hermes`, agent src ro |

Estado WebUI: `./data/hermes/webui/` (`HERMES_WEBUI_STATE_DIR`).

### Upgrade imagen agente

Tras `docker pull` o rebuild del agente, el volumen `hermes-agent-src` puede quedar stale (upstream #681). Procedimiento:

```bash
make down
docker volume rm hermes-test_hermes-agent-src   # prefijo = nombre del proyecto compose
make build && make up
```

## Seguridad (demo vs producción)

- **Demo LAN:** sin password en webui. Solo red de confianza.
- **Producción:** `HERMES_WEBUI_PASSWORD`, VPN/TLS, rotar `API_SERVER_KEY`. No publicar `:8642` fuera de Docker.

## Configurar modelo

| Comando | Cuándo |
|---------|--------|
| `make setup` | API key OpenRouter/OpenAI |
| `make setup-portal` | OAuth portal one-shot |

`scripts/seed-volume.sh` sincroniza `API_SERVER_KEY` con compose sin pisar keys LLM.

## Reseed

```bash
make seed && make up
```

Limpio: `make down && rm -rf data/hermes && make up`.

## Logs

```bash
make logs-webui
make logs-agent
make shell    # bash en acme-agent
```

## Troubleshooting

| Síntoma | Acción |
|---------|--------|
| GUI no carga | `docker compose ps`; `curl -w '%{http_code}' -o /dev/null localhost:8787` |
| Onboarding "Hermes" residual | Completar onboarding una vez; strings parcheados en build. Revisar `verify-branding.sh`. |
| Chat sin modelo | `make setup`; revisar `data/hermes/.env` |
| ~73 skills bundled | `make down && rm -rf data/hermes && make up` |
| Workspace vacío | Confirmar mount `./seed/company-docs:/workspace/docs:ro` |

## Backup

```bash
tar czf acme-agent-backup.tgz data/hermes/
```
