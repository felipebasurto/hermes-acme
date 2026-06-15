# Architecture — Acme Hermes demo

## Overview

```text
┌─────────────────────────────────────────────────────────┐
│  Host (Mac)                                             │
│  ~/code/hermes-acme                                     │
│                                                         │
│  ┌──────────────┐    rsync seed     ┌─────────────────┐ │
│  │ seed/        │ ───────────────► │ data/hermes/     │ │
│  │ (git)        │   (make seed)    │ (volume, .env)   │ │
│  └──────────────┘                  └────────┬─────────┘ │
│         │                                    │ mount    │
│         │ ro mount                           ▼          │
│  company-docs ─────────────────────► /opt/data (Hermes) │
│  /workspace/docs ──────────────────► /workspace/docs    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ acme-hermes       │
                    │ hermes-agent img  │
                    │ gateway run       │
                    │ :8642 API         │
                    │ :9119 dashboard   │
                    └───────────────────┘
```

## Components

### Docker service `acme-hermes`

- **Image:** `nousresearch/hermes-agent:latest`
- **Command:** `gateway run`
- **Ports:** 8642 (API), 9119 (dashboard)
- **Auth:** basic auth via env (`acme` / `changeme`)

### Volumes

| Host | Container | Mode | Content |
|------|-----------|------|---------|
| `./data/hermes` | `/opt/data` | rw | SOUL, skills, theme, config, `.env`, sessions |
| `./seed/company-docs` | `/workspace/docs` | ro | RFQ corpus, tarifas, plantillas |

### Seed pack (`seed/`)

Copied into `/opt/data` on `make seed`:

- **SOUL.md** — persona OT, BORRADOR, margen 18 %
- **AGENTS.md** — flujo, plantilla, prohibiciones
- **config.yaml** — `dashboard.theme: acme`
- **skills/** — 3 Acme skills (Hermes SKILL.md format)
- **dashboard-themes/** — `acme.yaml` + logo
- **memory/MEMORY.md** — brief context

Company knowledge stays in **`company-docs/`** (separate ro mount) so updates can be refreshed without full reseed if desired.

### Secrets boundary

| Location | Secrets? |
|----------|----------|
| Git repo | Never |
| `seed/` | Never |
| `./data/hermes/.env` | Yes — API keys after `make setup` |
| `./data/hermes/sessions/` | Runtime state — gitignored |

## Data flow — RFQ demo

1. User pastes RFQ in dashboard chat.
2. Hermes loads SOUL/AGENTS/skills from `/opt/data`.
3. Agent reads `/workspace/docs/*` for tarifas, AC-2024-017, plantilla v3.
4. Output: markdown borrador with BORRADOR banner — human sends to client.

## Non-goals (v1)

- No Hermes fork, no custom React UI
- No RAG service, CAD, Telegram
- No real client data

## References

- [Hermes Agent](https://github.com/NousResearch/hermes-agent)
- [Hermes Docker docs](https://hermes-agent.nousresearch.com/docs/user-guide/docker)
