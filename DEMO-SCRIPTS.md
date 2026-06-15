# Demo scripts — Acme Hermes

## Script A — 5 minute executive demo

**Audience:** Gerente / dirección industrial ficticia  
**Duration:** ~5 min

1. Show README quick start (3 pasos: `make build` → `make up` → `make setup`).
2. `make health` — contenedores verdes, GUI :3000 HTTP 200, API agente :8642 OK.
3. Browser: **http://localhost:3000** — la GUI web Acme abre directo, **sin login**, **sin terminal**.
4. Señala la marca Acme ("Acme Maquinaria Especial") y el modelo `acme-agent` en el selector. Cierra el modal de novedades si aparece ("Okay, Let's Go!").
5. Explica que la key del modelo solo vive en `./data/hermes/.env` tras `make setup`.
6. Si hay setup: pega la RFQ ejemplo-001 en el chat → borrador en ~1–2 min.
7. Resalta **BORRADOR**, cita de AC-2024-017 y la regla de margen ≥ 18 %.

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
