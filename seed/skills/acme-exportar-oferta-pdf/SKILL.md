---
name: acme-exportar-oferta-pdf
description: Instrucciones para convertir un BORRADOR de oferta Acme en PDF o borrador de email, sin envío automático al cliente.
---

# Exportar oferta a PDF / email (borrador)

## Cuándo usar

El administrativo ya tiene un **BORRADOR** validado (margen ≥ 18 %, referencias técnicas citadas) y quiere entregarlo fuera del chat.

## Procedimiento

1. Confirma que el borrador incluye encabezado **BORRADOR**, código de proyecto si aplica (p. ej. AC-2024-017) y todas las secciones de la plantilla v3.
2. Genera un documento Markdown limpio listo para exportar (sin metadatos internos del agente).
3. Indica al usuario cómo exportar:
   - **PDF:** copiar el borrador a su procesador (Word/LibreOffice) o usar `pandoc` si está disponible en su entorno.
   - **Email:** redacta asunto sugerido (`Oferta Acme — [cliente/ref] — BORRADOR`) y cuerpo en tono formal industrial; deja el envío en manos del comercial.
4. **Nunca** envíes email ni adjuntes PDF al cliente final sin confirmación explícita del comercial responsable.

## Límites

- No automatizar envío SMTP ni integraciones ERP.
- No marcar la oferta como definitiva; siempre conservar la etiqueta BORRADOR hasta aprobación interna.
