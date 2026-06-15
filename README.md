# Acme Hermes — reference deployment

Despliegue white-label del [Hermes Agent](https://github.com/NousResearch/hermes-agent) (MIT) para **Acme Maquinaria Especial S.L.** — RFQ → borrador oferta técnica. Panel administrativo simplificado, marca Acme, sin login en demo LAN.

Cliente industrial ficticio de Burgos. **Sin API keys en el repo.**

## Quick start (3 pasos)

```bash
cd ~/code/hermes-acme
make up          # seed del volumen + arranca gateway + dashboard (sin login)
make setup       # una vez: asistente Hermes — API key (OpenRouter/Portal) → data/hermes/.env
# Abre el panel: http://localhost:9119   (demo sin usuario/contraseña)
```

**Las API keys viven solo en `./data/hermes/.env`**, creado por `make setup`. Nunca se commitean.

OAuth opcional (Nous Portal):

```bash
make setup-portal
```

Smoke check:

```bash
make health
```

## Demo

Pega la RFQ de `seed/company-docs/rfq/ejemplo-entrada-001.txt` en el chat del panel (tras `make setup`). El agente devuelve un **BORRADOR** de oferta citando el proyecto análogo `AC-2024-017`.

## Panel administrativo

- **Sin login** en demo LAN (`HERMES_DASHBOARD_INSECURE=1`). En producción va detrás de VPN/SSO/reverse proxy — ver [docs/RUNBOOK.md](docs/RUNBOOK.md).
- **Marca Acme**: tema `acme` por defecto, logo y colores Acme, sin referencias Nous visibles ni selector de temas.
- **Navegación simplificada**: Chat, Sesiones, Skills, Docs, Config.
- **Solo skills Acme** (marcador `seed/.no-bundled-skills` evita los ~73 skills genéricos del bundle).

El white-label usa solo mecanismos soportados de Hermes (tema YAML + plugin UI), sin fork. Detalles y tradeoffs en [HANDOFF.md](HANDOFF.md).

## Layout

| Path | Purpose |
|------|---------|
| `seed/` | SOUL, AGENTS, skills, tema, config (versionado) |
| `seed/.no-bundled-skills` | Marcador: deja solo los skills Acme (no sincroniza el bundle) |
| `seed/dashboard-themes/acme.yaml` | Tema Acme (paleta, logo, white-label CSS) |
| `seed/plugins/acme-admin/` | Plugin UI Acme (título + favicon del navegador) |
| `seed/company-docs/` | Corpus ficticio (montado solo-lectura en `/workspace/docs`) |
| `data/hermes/` | Volumen runtime (gitignored `.env` y `sessions/`) |
| `docker-compose.yml` | Servicio `nousresearch/hermes-agent` (sin login, API opcional) |
| `scripts/` | Helpers de seed y health |

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
