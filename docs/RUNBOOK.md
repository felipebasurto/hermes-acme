# Runbook — Acme Agent v3

## Prerequisitos

- Docker Engine + Compose v2 (`docker compose`). El `Makefile` usa `docker compose` por defecto.
- Puertos libres en el host: **3000** (GUI Acme) y **8642** (API del agente).

## Primer arranque

```bash
make build        # imagen fork local del agente
make up           # GUI + agente headless
make setup        # interactivo — escribe ./data/hermes/.env con la API key del modelo
make health
```

GUI: **http://localhost:3000** (demo sin login).

## Seguridad (demo vs producción)

- **Demo LAN:** la GUI corre con `WEBUI_AUTH=false` (sin login) y el agente no expone dashboard. Aceptable **solo en LAN/host de confianza**.
- **Producción:** no exponer `:3000` ni `:8642` abiertos. Poner la GUI detrás de **VPN** (WireGuard/Tailscale), **reverse proxy con TLS + auth/SSO**, y activar el login de Open WebUI (`WEBUI_AUTH=true`). Rotar `API_SERVER_KEY`. El `:8642` del agente debe quedar solo en la red interna de Docker.

## Configurar modelo (una vez)

| Comando | Cuándo |
|---------|--------|
| `make setup` | Pegar API key (OpenRouter/OpenAI) en el asistente |
| `make setup-portal` | OAuth Nous Portal one-shot |

La key vive **solo** en `./data/hermes/.env` (gitignored). Hasta entonces el chat devuelve "proveedor no configurado".

## Reseed tras git pull

```bash
make seed && make up
```

`seed-volume.sh` usa `rsync` y nunca sobrescribe `.env`. El marcador `.no-bundled-skills` se siembra desde `seed/` y evita los ~73 skills del bundle.

> Si el volumen ya estaba poblado (el contenedor lo dejó con uid 10000), un reseed limpio es: `make down && sudo rm -rf data/hermes && make up`.

## Logs y shell

```bash
make logs                              # todos los servicios
docker compose logs -f acme-agent      # solo el agente
make shell                             # bash dentro de acme-agent
```

## Parar

```bash
make down
```

## Troubleshooting

| Síntoma | Acción |
|---------|--------|
| GUI no carga | `docker compose ps`; mira `acme-chat`; `curl -s -o /dev/null -w "%{http_code}" localhost:3000` |
| Modal "What's New" con texto Open WebUI | Es el changelog upstream de primer arranque; se cierra con "Okay, Let's Go!" y no reaparece (estado en `data/open-webui`) |
| Chat sin respuesta / "proveedor no configurado" | Ejecuta `make setup`; confirma `data/hermes/.env` |
| El selector muestra otro modelo | Debe ser `acme-agent` (`API_SERVER_MODEL_NAME`); reinicia `acme-agent` |
| Aparecen ~73 skills | Falta el marcador; `make down && sudo rm -rf data/hermes && make up` |
| Puerto ocupado | Cambia el mapeo de puertos en `docker-compose.yml` |

## Backup

```bash
tar czf acme-agent-backup.tgz data/hermes/ data/open-webui/
```

Excluir de backups compartidos si `.env` contiene keys productivas.
