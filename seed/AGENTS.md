# AGENTS — Acme Hermes workspace

## Plantilla de oferta

- **Ruta:** `/workspace/docs/oferta-acme-v3.md`
- Toda oferta técnica debe seguir esa estructura de secciones (ver abajo).
- Guardar borradores con nombre `BORRADOR-AC-YYYY-NNN-oferta-<cliente>.md` en el workspace del agente.

## Tarifas (referencia interna)

| Documento | Contenido |
|-----------|-----------|
| `/workspace/docs/tarifas-mecanica.md` | Horas taller, mecanizado, montaje |
| `/workspace/docs/tarifas-automatizacion.md` | PLC, visión, integración, puesta en marcha |

No extrapolar tarifas fuera de estos documentos. Aplicar factor de complejidad según `flujo-oferta.md`.

## Flujo comercial

Seguir `/workspace/docs/flujo-oferta.md`:

1. Entrada RFQ (email, portal, teléfono) → registro interno.
2. OT (María) clasifica y asigna referencia `AC-YYYY-NNN` provisional.
3. Borrador técnico-económico con plantilla v3.
4. Revisión comercial (Juan) + margen ≥ 18 % (Gerente si excepción).
5. **Solo humanos** envían PDF firmado al cliente.

## Prohibido

- Auto-envío de ofertas, emails o PDFs al cliente.
- Comprometer plazos de entrega sin validación OT.
- Publicar precios finales sin revisión comercial.
- Usar datos de clientes reales (todo el corpus es ficticio).

## Secciones obligatorias en toda oferta

1. Portada (cliente, referencia AC, fecha, validez)
2. Resumen ejecutivo
3. Alcance técnico y exclusiones
4. Supuestos del cliente
5. Desglose económico (partidas + totales)
6. Plazo de ejecución y hitos
7. Condiciones de pago (ver `condiciones-generales-venta.md`)
8. Validez de la oferta
9. Anexos técnicos (layout, BOM preliminar si aplica)
10. Pie legal Acme + **BORRADOR — NO ENVIAR**

## Skills disponibles

- `acme-rfq-a-oferta` — RFQ → borrador oferta
- `acme-memoria-proyectos` — buscar proyectos análogos (AC-2024-017 hero)
- `acme-checklist-cierre` — QA antes de pasar a comercial
