---
name: acme-validar-plazo
description: Valida el plazo pedido en una RFQ contra los plazos estándar de Acme y señala riesgos de entrega
version: 1.0.0
metadata:
  hermes:
    tags: [acme, plazo, riesgos, planificacion]
    category: acme
---

# Validación de plazo

## When to Use

La RFQ indica un plazo de entrega y hay que comprobar si es realista frente a la experiencia de Acme antes de comprometerlo en el borrador.

## Procedure

1. Extraer el plazo pedido de la RFQ (semanas laborables salvo indicación contraria).
2. Comparar con el proyecto análogo `/workspace/docs/proyecto-AC-2024-017.md` (referencia real de plazo).
3. Aplicar buffers de ingeniería del `/workspace/docs/flujo-oferta.md` (p.ej. +2 semanas en ambiente lavado, +1 por cambio de formato rápido).
4. Si el plazo pedido < plazo estimado: marcar **RIESGO PLAZO** y proponer alternativas (fases, alcance reducido, ampliación de plazo).
5. Nunca comprometer plazos sin validación de OT (María).
6. Devolver: plazo pedido, plazo estimado Acme, gap, hitos y riesgos.

## Pitfalls

- No igualar el plazo del cliente "para ganar la oferta" sin buffer.
- No olvidar plazos de aprovisionamiento de componentes críticos (PLC, visión).
- Un plazo agresivo sin riesgo documentado es una bandera roja.

## Verification

- Plazo estimado citado contra AC-2024-017 (18 semanas reales de referencia).
- Si hay gap, existe línea RIESGO PLAZO con mitigación.
- Hitos en semanas laborables.
