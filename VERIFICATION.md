# Verification checklist — Acme Hermes

Run from repo root after `make up`.

## Infrastructure (no API key required)

| Check | Command / action | Expected |
|-------|------------------|----------|
| Container running | `make health` (Docker section) | `acme-hermes` Up |
| Dashboard reachable | curl in `make health` | HTTP 200 with basic auth |
| Gateway health | curl :8642/health | HTTP 200 or 404 if route differs |
| Seed on volume | `ls data/hermes/SOUL.md` | File exists after `make up` |
| Theme files | `ls data/hermes/dashboard-themes/acme.yaml` | Present |
| Skills | `ls data/hermes/skills/` | 3 skill directories |
| Company docs mount | `make shell` → `ls /workspace/docs` | 14+ files |
| .env gitignored | `git status` | `data/hermes/.env` not tracked |

## Content spot checks

- [ ] `seed/SOUL.md` mentions BORRADOR, AC-YYYY-NNN, margen 18 %
- [ ] `seed/company-docs/rfq/ejemplo-entrada-001.txt` contains bandejas 400×300, 120 u/min
- [ ] `seed/company-docs/proyecto-AC-2024-017.md` exists (hero project)
- [ ] `seed/config.yaml` → `dashboard.theme: acme`

## LLM chat test

**SKIPPED — run `make setup` first** if `data/hermes/.env` is missing.

After setup:

1. Open http://localhost:9119 (acme/changeme)
2. Paste RFQ from `ejemplo-entrada-001.txt`
3. Expect borrador markdown with BORRADOR, referencia AC, citas AC-2024-017, secciones plantilla v3

Record pass/fail and model used in handoff notes.

## Evidence log

| Date | Operator | make up | make health | setup | chat demo |
|------|----------|---------|-------------|-------|-----------|
| | | | | | |
