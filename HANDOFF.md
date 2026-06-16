# Handoff — Acme Agent v4

## Repo / rama

- Remote: https://github.com/felipebasurto/hermes-acme
- Rama: `main`
- Migración: Open WebUI (v3) → fork hermes-webui (v4)

## Qué se entregó (v4)

- **GUI cliente** `acme-webui` (fork MIT hermes-webui) en `:8787`, agent-native (sesiones, tools, workspace, skills).
- **Agente** `acme-agent`: `acme-hermes-agent:local`, `HERMES_DASHBOARD=0`, gateway compartiendo `./data/hermes`.
- **Open WebUI eliminado** (`acme-chat`, `data/open-webui/`).
- **8 skills Acme** + `.no-bundled-skills`.
- **Build the Lever:** `scripts/patch-webui-branding.sh`, `scripts/verify-branding.sh`, `docker/webui/Dockerfile`.
- Docs v4: README, ARCHITECTURE, RUNBOOK, CLIENT-PACK, DEMO-SCRIPTS, VERIFICATION.

## Forks y pins

| Componente | Upstream | Fork / build | Pin SHA |
|------------|----------|--------------|---------|
| WebUI | https://github.com/nesquena/hermes-webui | Build local `acme-hermes-webui:local` (fork remoto objetivo: https://github.com/felipebasurto/hermes-webui-acme) | `dc90ec9be4f2691a60d2413350405f2758a340a2` |
| Agente | nousresearch/hermes-agent:latest | `acme-hermes-agent:local` (Dockerfile raíz) | tag `latest` al build |

> **Nota fork remoto:** `felipebasurto/hermes-webui-acme` debe crearse pushando el tree parcheado (mismo pin + patch script). En esta sesión el parche vive en hermes-acme (`docker/webui/Dockerfile` clona upstream en build). GH CLI no autenticado en VM.

## Ficheros parcheados (webui)

Aplicados por `scripts/patch-webui-branding.sh` sobre clone upstream:

- `static/index.html`, `manifest.json`, `sw.js`, `i18n.js`, `ui.js`, `panels.js`, `onboarding.js`, `sessions.js`, `boot.js`
- `api/config.py`, `routes.py`, `onboarding.py`, `passkeys.py`, `models.py` (defaults `bot_name`)
- `static/favicon*.svg/png`, `apple-touch-icon.png` ← logo Acme

Agente (sin cambio v4): `Dockerfile` raíz parchea assets servidos del dashboard embebido (defensa en profundidad, dashboard OFF).

## Decisiones clave (principios poteto)

| Principio | Decisión |
|-----------|----------|
| **Experience First** | hermes-webui agent-native en lugar de Open WebUI chatbot-only |
| **Subtract Before You Add** | Eliminado acme-chat antes de añadir acme-webui |
| **Build the Lever** | patch-webui-branding.sh + verify-branding.sh idempotentes |
| **Prove It Works** | VERIFICATION.md con output de curl/grep/compose |
| **Encode Lessons in Structure** | API_SERVER_KEY sync en seed-volume.sh |
| **Boundary Discipline** | Agente gateway vs webui presentación; contrato = volumen `data/hermes` |

## StackState

```yaml
hermes_home: ./data/hermes
webui_state: ./data/hermes/webui
workspace: /workspace/docs  # seed/company-docs ro
agent_image: acme-hermes-agent:local
webui_image: acme-hermes-webui:local
```

Puerto cliente documentado: **8787**.

## Qué se verificó

Ver `VERIFICATION.md`. Resumen: stack PASS, branding PASS, 8 skills PASS, chat RFQ **SKIPPED** (sin LLM key).

## Límites conocidos

- Chat con modelo requiere `make setup` (cliente).
- Known upstream #681: tools desde webui corren en contenedor webui (documentado en RUNBOOK).
- Onboarding wizard en primer arranque (copy parcheado; completar una vez).
- Fork GitHub `hermes-webui-acme` pendiente de push remoto si no existía.

## Reproducir

```bash
make build && make up
make health
./scripts/verify-branding.sh
open http://localhost:8787
make setup   # LLM key
```

## Anti-patterns evitados

- No reintroducir Open WebUI.
- No usar OpenAI shim como UX principal.
- No marcar done sin evidencia curl/grep.
