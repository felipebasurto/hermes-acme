---
name: acme-calculo-margen
description: Calcula el margen bruto de una oferta Acme con tarifas internas y alerta si queda por debajo del 18 % mínimo
version: 1.0.0
metadata:
  hermes:
    tags: [acme, margen, tarifas, comercial]
    category: acme
---

# Cálculo de margen Acme

## When to Use

Hay un desglose de partidas (horas taller, mecanizado, automatización, compras) y se necesita confirmar que la oferta cumple el margen mínimo antes de pasar a comercial.

## Procedure

1. Reunir las partidas de coste desde `/workspace/docs/tarifas-mecanica.md` y `/workspace/docs/tarifas-automatizacion.md`. No usar tarifas externas.
2. Sumar coste directo (materiales + horas) y aplicar el factor de complejidad de `/workspace/docs/flujo-oferta.md`.
3. Calcular precio de venta y margen bruto: `margen = (PV - coste) / PV`.
4. Comparar contra la política de `/workspace/docs/politica-margenes.md` (mínimo 18 %).
5. Si `margen < 18 %`: marcar **ALERTA MARGEN** y escalar a Gerente; proponer ajustes (alcance, plazo, partidas opcionales).
6. Devolver tabla: partida, coste, PV, margen por línea y margen total.

## Pitfalls

- No inventar precios unitarios fuera de las tarifas internas.
- No compensar margen bajo recortando ingeniería o puesta en marcha.
- El IVA no entra en el cálculo de margen bruto.

## Verification

- Margen total expresado en % con un decimal.
- Si < 18 %, existe línea ALERTA MARGEN con destinatario (Gerente).
- Toda cifra trazable a una partida de tarifas internas.
