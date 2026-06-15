---
name: acme-checklist-cierre
description: Checklist de cierre OT/comercial antes de pasar un borrador de oferta a Juan o al Gerente
version: 1.0.0
metadata:
  hermes:
    tags: [acme, checklist, calidad, oferta]
    category: acme
---

# Checklist de cierre — borrador oferta

## When to Use

Un borrador de oferta está redactado y debe validarse antes de revisión comercial humana.

## Procedure

Recorrer y marcar OK / PENDIENTE / N/A:

1. **Encabezado BORRADOR** visible en portada y pie.
2. **Referencia AC-YYYY-NNN** asignada o provisional documentada.
3. **10 secciones** de `oferta-acme-v3.md` completas.
4. **Supuestos del cliente** explícitos (dimensiones bandeja, u/min, ambiente lavado, plazo pedido).
5. **Exclusiones** listadas (obras civiles, utilities, formación operarios si no contratada).
6. **Tarifas** trazables a documentos tarifarios (sin cifras inventadas).
7. **Margen bruto ≥ 18 %** o alerta escrita para Gerente.
8. **Plazo** con hitos y buffer ingeniería (+2 sem sem lavado).
9. **Condiciones de pago** alineadas con `condiciones-generales-venta.md`.
10. **Validez 30 días** indicada.
11. **Sin auto-envío** — recordatorio de que solo humanos envían al cliente.
12. **Anexos** referenciados (layout preliminar, normativa inocuidad si aplica).

## Pitfalls

- Aprobar checklist con partidas `[PENDIENTE]` sin listar quién debe completarlas.
- Confundir borrador interno con PDF firmado.

## Verification

Entregar tabla markdown OK/PENDIENTE/N/A y lista de acciones abiertas para María o Juan.
