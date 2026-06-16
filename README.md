# Acme Agent — despliegue de referencia (v4)

Agente de oficina técnica para **Acme Maquinaria Especial S.L.** (cliente industrial ficticio, Burgos). Convierte RFQ en **borrador de oferta técnica**. Los administrativos usan una **GUI de agente nativa** (sesiones, tools, workspace) en fork MIT de Hermes WebUI. El agente Hermes corre headless como gateway.

**Sin API keys en el repo.** La key del modelo va en `./data/hermes/.env` vía `make setup`.

## Quick start

```bash
make build      # acme-hermes-agent:local + acme-hermes-webui:local
make up         # acme-agent + acme-webui (two-container)
make setup      # API key OpenRouter/OpenAI → data/hermes/.env
```

Abre la GUI Acme: **http://localhost:8787** (demo sin password).

> Sin `make setup` la GUI carga, pero el agente responde "No inference provider configured" hasta que el cliente añade su key.

```bash
make health
./scripts/verify-branding.sh
```

## Arquitectura (resumen)

```
navegador (admin) ──> acme-webui (hermes-webui fork, :8787)
                          │  gateway nativo (sesiones, tools, workspace)
                          ▼
                      acme-agent (Hermes headless, gateway, dashboard OFF)
                          │  persona + 8 skills + corpus
                          ▼
                      data/hermes  +  seed/company-docs
```

Detalle en [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Layout

| Path | Propósito |
|------|-----------|
| `Dockerfile` | Fork parche → `acme-hermes-agent:local` |
| `docker/webui/Dockerfile` | Fork hermes-webui → `acme-hermes-webui:local` |
| `scripts/patch-webui-branding.sh` | White-label idempotente de la GUI |
| `docker-compose.yml` | `acme-webui` + `acme-agent` |
| `seed/skills/` | 8 skills Acme (`acme-*`) |
| `seed/.no-bundled-skills` | Solo skills Acme (sin bundle ~73) |
| `seed/company-docs/` | Corpus ficticio (`/workspace/docs` ro) |
| `data/hermes/` | Volumen compartido (`.env`, `webui/`, sessions gitignored) |

## Make targets

- `make build` — construye agente + webui
- `make up` / `make down` — stack two-container
- `make setup` / `make setup-portal` — credenciales LLM
- `make seed` / `make health` / `make logs` / `make logs-webui` / `make logs-agent` / `make shell`

## Docs

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [docs/RUNBOOK.md](docs/RUNBOOK.md)
- [docs/CLIENT-PACK.md](docs/CLIENT-PACK.md)
- [DEMO-SCRIPTS.md](DEMO-SCRIPTS.md)
- [VERIFICATION.md](VERIFICATION.md)
- [HANDOFF.md](HANDOFF.md)
