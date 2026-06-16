# Demo scripts — Acme Hermes v4

## Script A — 5 minute executive demo

**Audience:** Gerente / dirección industrial ficticia  
**Duration:** ~5 min

1. README quick start: `make build` → `make up` → `make setup`.
2. `make health` — `acme-agent` + `acme-webui` Up, :8787 HTTP 200.
3. `./scripts/verify-branding.sh` — white-label PASS.
4. Browser: **http://localhost:8787** — GUI agente Acme, sin password en demo.
5. Señala sesiones en sidebar, workspace/docs, panel skills. Título **Acme Maquinaria Especial**.
6. Nueva sesión → pega RFQ ejemplo-001 (Script C).
7. Resalta tool cards si el agente invoca herramientas, BORRADOR, AC-2024-017, margen ≥ 18 %.

**Talking point:** GUI de agente (no chatbot genérico). Días de oferta → minutos de borrador.

## Script B — OT deep dive (María)

1. En webui: workspace browser → `/workspace/docs`.
2. Walk `proyecto-AC-2024-017.md` vs RFQ Norte.
3. Skills panel: `acme-rfq-a-oferta`, `acme-escalar-a-maria`.
4. Checklist skill sobre el borrador.

## Script C — RFQ ejemplo-001 (canonical)

**Input** (`seed/company-docs/rfq/ejemplo-entrada-001.txt`):

```
Buenos días,
Necesitamos línea de envasado para bandejas 400×300 mm, 120 uds/min,
cambio de formato rápido. Ambiente lavado. Plazo 14 semanas.
¿Precio y plazo orientativo?
Saludos, Compras — Hostelería Industrial Norte S.L.
```

**Expected:**

- Cita **AC-2024-017**, plantilla v3, tarifas del corpus
- Flag plazo 14 vs 18 semanas
- **BORRADOR — REVISIÓN HUMANA OBLIGATORIA**
- Margen ≥ 18 % o nota de escalada (`acme-escalar-a-maria`)

**Sin LLM:** infra + branding PASS; chat SKIPPED (ver VERIFICATION.md).

## Script D — Reseed safety

1. Dummy `data/hermes/.env` con `TEST=1` y key LLM ficticia.
2. `make seed` — preserva keys LLM, sincroniza `API_SERVER_KEY`.

## Reset demo

```bash
make down
rm -rf data/hermes
make up
make setup   # si demo chat con modelo
```
