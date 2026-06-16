---
name: acme-redactar-seccion-tecnica
description: Redacta las secciones técnicas de un borrador de oferta siguiendo la plantilla oferta-acme-v3
version: 1.0.0
metadata:
  hermes:
    tags: [acme, oferta, redaccion, tecnica]
    category: acme
---

# Redacción de sección técnica (plantilla v3)

## When to Use

Ya hay un alcance acordado y se necesita redactar las secciones técnicas (alcance, exclusiones, supuestos, anexos) del borrador con la estructura oficial.

## Procedure

1. Abrir `/workspace/docs/oferta-acme-v3.md` y respetar el orden de las 10 secciones obligatorias (ver AGENTS.md).
2. Redactar en español técnico, unidades SI, frases cortas. Sin marketing.
3. Alcance técnico: qué entra, con cadencia, formato y ambiente (p.ej. lavado / inocuidad alimentaria — ver `/workspace/docs/normativa-inocuidad-alimentaria.md`).
4. Exclusiones explícitas: suministros eléctricos en obra, obra civil, licencias de terceros.
5. Supuestos del cliente: tensión, aire comprimido, espacio, integración con líneas existentes.
6. Anexos: layout preliminar y BOM si aplica; citar proyecto análogo `AC-2024-017` cuando proceda.
7. Encabezar con **BORRADOR — REVISIÓN HUMANA OBLIGATORIA**.

## Pitfalls

- No comprometer prestaciones no validadas por OT (María).
- No omitir exclusiones: son la principal fuente de sobrecoste.
- No mezclar precios en la sección técnica (van en el desglose económico).

## Verification

- Las secciones técnicas siguen el orden de la plantilla v3.
- Exclusiones y supuestos presentes y explícitos.
- Glosario coherente con `/workspace/docs/glosario-tecnico-acme.md`.
