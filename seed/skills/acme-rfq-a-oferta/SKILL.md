---
name: acme-rfq-a-oferta
description: Convierte una RFQ (email o texto) en borrador de oferta técnica Acme usando plantilla v3 y tarifas internas
version: 1.0.0
metadata:
  hermes:
    tags: [acme, rfq, oferta, comercial]
    category: acme
---

# RFQ → Borrador de oferta Acme

## When to Use

El usuario pega o adjunta una solicitud de presupuesto (RFQ) para maquinaria, línea de envasado o utillaje. Objetivo: borrador interno, no envío al cliente.

## Procedure

1. Leer la RFQ y listar datos faltantes (dimensiones, cadencia, ambiente, plazo, normativa).
2. Buscar proyecto análogo en `/workspace/docs/proyecto-AC-2024-017.md` y otros corpus.
3. Abrir plantilla `/workspace/docs/oferta-acme-v3.md` y rellenar todas las secciones obligarias (ver AGENTS.md).
4. Calcular partidas con `/workspace/docs/tarifas-mecanica.md` y `/workspace/docs/tarifas-automatizacion.md`.
5. Aplicar factor de complejidad según `/workspace/docs/flujo-oferta.md`.
6. Verificar margen bruto ≥ 18 %; si no, marcar alerta para Gerente.
7. Encabezar documento con **BORRADOR — REVISIÓN HUMANA OBLIGATORIA**.
8. Proponer referencia provisional `AC-2026-XXX` si no existe.

## Pitfalls

- No inventar precios unitarios no listados en tarifas.
- No prometer plazo sin margen de ingeniería (+2 semanas buffer en ambiente lavado).
- No omitir exclusiones (suministros eléctricos en obra, licencias software de terceros).

## Verification

- Todas las 10 secciones de la plantilla v3 presentes.
- Al menos una cita `AC-YYYY-NNN`.
- Pie con BORRADOR y validez 30 días estándar Acme.
