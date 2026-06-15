# Client pack — Acme Hermes reference

What you would deliver to a fictional client **Acme Maquinaria Especial** as a packaged workspace (demo scope).

## Included in repo

| Deliverable | Description |
|-------------|-------------|
| Docker Compose stack | Single-service Hermes gateway + dashboard |
| Seed identity | SOUL.md, AGENTS.md, MEMORY.md (Spanish OT persona) |
| 3 skills | RFQ→oferta, memoria proyectos, checklist cierre |
| Dashboard theme | `acme` — industrial steel, amber/blue, logo |
| Company corpus | 14 docs under `seed/company-docs/` (fictional) |
| Runbook + demo scripts | Operations and sales demo path |

## Client responsibilities

1. Provide LLM credentials via `make setup` (keys stay in their volume).
2. Change dashboard basic auth password before production-like deploy.
3. Human review of every borrador before customer send (governance in SOUL).

## Customization levers

- **Persona:** edit `seed/SOUL.md`, reseed
- **Tarifas / plantilla:** edit `seed/company-docs/`, restart not required for docs mount
- **Theme:** edit `seed/dashboard-themes/acme.yaml`
- **Skills:** add/edit under `seed/skills/*/SKILL.md`

## Out of scope (upsell)

- ERP/MCP connectors
- NVIDIA RAG ingest pipeline
- Multi-tenant hosting
- Signed PDF generation workflow

## Support model (demo)

Internal DMKINGS-style handoff: client IT runs Docker on a Mac or Linux host; Acme OT owns content in `seed/`.

## License

Hermes Agent: MIT (Nous Research). Seed content in this repo: fictional demo data, same repo license as stated by maintainer.
