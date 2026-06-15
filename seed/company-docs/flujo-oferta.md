# Flujo comercial — RFQ a oferta firmada

Proceso interno Acme (ficticio). Hermes asiste solo en fases 2–3.

## 1. Entrada RFQ

Canales: email `comercial@acme-maquinaria.demo`, teléfono, feria.  
Registro en CRM interno (no integrado en demo).

## 2. Clasificación OT (María)

- Asignar referencia provisional `AC-YYYY-NNN`.
- Etiquetar sector: automoción / alimentación / general.
- SLA interno: primera respuesta al cliente < 48 h (ack, no oferta).

## 3. Borrador técnico-económico

- Plantilla: `oferta-acme-v3.md`
- Tarifas: `tarifas-mecanica.md`, `tarifas-automatizacion.md`
- Proyecto análogo obligatorio si existe (p. ej. AC-2024-017 en envasado bandejas)

### Factores de complejidad

| Factor | Multiplicador horas ingeniería |
|--------|-------------------------------|
| Estándar | 1,0 |
| Ambiente lavado / IP65 extendido | 1,12 |
| Cambio formato < 30 min | 1,08 |
| Integración visión rechazo | 1,10 |
| Cliente sin layout de planta | 1,05 (riesgo, no precio) |

## 4. Revisión comercial (Juan)

- Coherencia alcance vs precio.
- Ajuste márgenes por estrategia cuenta.
- **Margen bruto mínimo: 18 %.** Por debajo → escalado a Gerente.

## 5. Aprobación Gerente

- Excepciones de margen.
- Riesgos de plazo agresivo (< 14 sem en línea completa lavada).

## 6. Emisión PDF firmado

- Solo humanos. Hermes **nunca** envía al cliente.
- Archivo en servidor documental (fuera de alcance demo).

## Prohibiciones explícitas para el agente

- Auto-envío email/PDF.
- Comprometer descuentos > 3 % sin Juan.
- Fechar validez distinta a 30 días sin comercial.
