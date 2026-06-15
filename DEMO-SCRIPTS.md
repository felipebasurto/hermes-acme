# Demo scripts — Acme Hermes

## Script A — 5 minute executive demo

**Audience:** Gerente / dirección industrial ficticia  
**Duration:** ~5 min

1. Show README quick start (3 steps).
2. `make health` — container green, dashboard 200 (sin login).
3. Browser: http://localhost:9119 — abre directo, **sin login**.
4. Point out marca Acme (logo, acero/ámbar, "Maquinaria Especial · Burgos"), navegación simplificada y que no hay referencias Nous ni selector de temas.
5. Explain keys only in `./data/hermes/.env` after `make setup`.
6. If setup done: paste RFQ ejemplo-001 → borrador in ~1–2 min.
7. Highlight **BORRADOR** and margen 18 % rule.

**Talking point:** "Días de oferta → minutos de borrador; humano sigue mandando."

## Script B — OT deep dive (María)

1. Open `/workspace/docs` corpus (via chat or `make shell`).
2. Walk `proyecto-AC-2024-017.md` vs RFQ Norte.
3. Show `flujo-oferta.md` complexity factors.
4. Invoke skill narrative: `/acme-rfq-a-oferta` or natural language equivalent.
5. Run checklist skill on output — table OK/PENDIENTE.

## Script C — RFQ ejemplo-001 (canonical)

**Input** (from `seed/company-docs/rfq/ejemplo-entrada-001.txt`):

```
Buenos días,
Necesitamos línea de envasado para bandejas 400×300 mm, 120 uds/min,
cambio de formato rápido. Ambiente lavado. Plazo 14 semanas.
¿Precio y plazo orientativo?
Saludos, Compras — Hostelería Industrial Norte S.L.
```

**Expected agent behavior:**

- Ask/clarify missing details OR document assumptions explicitly
- Cite **AC-2024-017** as analog
- Use `oferta-acme-v3.md` section structure
- Pull rates from tarifas docs (no invented unit prices)
- Flag 14 weeks vs 18 weeks actual on AC-2024-017
- Mark **BORRADOR — REVISIÓN HUMANA OBLIGATORIA**
- Show margen ≥ 18 % or escalation note

**If LLM not configured:** state demo stops at infrastructure; run `make setup`.

## Script D — Reseed safety

1. Create dummy `data/hermes/.env` with `TEST=1`
2. `make seed`
3. Confirm `.env` still contains `TEST=1`

## Reset demo

```bash
make down
rm -rf data/hermes
make up
make setup   # if chat demo needed
```
