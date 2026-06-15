# Acme Agent — despliegue de referencia (v3)

Agente de oficina técnica para **Acme Maquinaria Especial S.L.** (cliente industrial ficticio, Burgos) que convierte RFQ en **borrador de oferta técnica**. Los administrativos usan una **GUI web de chat** (sin terminal, sin login en demo); el agente Hermes corre headless detrás, con marca upstream parcheada y solo skills Acme.

**Sin API keys en el repo.** La key del modelo va en `./data/hermes/.env` vía `make setup`.

## Quick start (3 pasos)

```bash
make build      # construye la imagen fork local del agente (acme-hermes-agent:local)
make up         # arranca GUI (acme-chat) + agente headless (acme-agent)
make setup      # una vez: asistente del agente — API key (OpenRouter/OpenAI) → data/hermes/.env
```

Abre la GUI Acme: **http://localhost:3000** (demo sin login). Escribe la RFQ en el chat.

> Sin `make setup` la GUI carga y acepta mensajes, pero el agente responde "proveedor no configurado" hasta que el cliente añade su key.

Smoke check:

```bash
make health
```

## Arquitectura (resumen)

```
navegador (admin) ──> acme-chat (Open WebUI, :3000, marca Acme, sin login)
                          │  POST /v1/chat/completions
                          ▼
                      acme-agent (Hermes headless, :8642/v1, dashboard OFF)
                          │  persona + 6 skills + corpus
                          ▼
                      data/hermes  +  seed/company-docs (AC-2024-017, tarifas, plantilla)
```

Detalle y decisión de GUI en [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Layout

| Path | Propósito |
|------|-----------|
| `Dockerfile` | Fork de parche → `acme-hermes-agent:local` (marca upstream parcheada) |
| `docker-compose.yml` | `acme-chat` (GUI) + `acme-agent` (Hermes headless) |
| `seed/skills/` | 6 skills Acme (`acme-*`) en formato SKILL.md |
| `seed/.no-bundled-skills` | Marcador: solo skills Acme (sin los ~73 del bundle) |
| `seed/company-docs/` | Corpus ficticio (montado ro en `/workspace/docs`) |
| `seed/dashboard-themes/acme.yaml` | Tema Acme (si se reactivara el dashboard interno) |
| `data/hermes/` | Volumen runtime (`.env` y `sessions/` gitignored) |

## Make targets

- `make build` — construye la imagen fork del agente
- `make up` / `make down` — arranca/para el stack
- `make setup` / `make setup-portal` — credenciales del modelo (no van a git)
- `make seed` / `make health` / `make logs` / `make shell`

## Docs

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — decisión GUI, diagrama, componentes
- [docs/RUNBOOK.md](docs/RUNBOOK.md) — operación, demo LAN vs producción
- [docs/CLIENT-PACK.md](docs/CLIENT-PACK.md) — qué se entrega al cliente
- [DEMO-SCRIPTS.md](DEMO-SCRIPTS.md) — guion de demo (RFQ por la GUI)
- [VERIFICATION.md](VERIFICATION.md) — checklist con evidencia v3
- [HANDOFF.md](HANDOFF.md) — notas de traspaso v3
