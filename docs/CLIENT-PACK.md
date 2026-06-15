# Client pack — Acme Agent v3

Qué se entrega al cliente ficticio **Acme Maquinaria Especial** como workspace empaquetado (alcance demo/mock).

## Incluido en el repo

| Entregable | Descripción |
|------------|-------------|
| Stack Docker Compose | `acme-chat` (GUI web) + `acme-agent` (Hermes headless) |
| Imagen fork local | `Dockerfile` → `acme-hermes-agent:local`, marca upstream parcheada |
| GUI white-label | Open WebUI rebrandeado a "Acme Maquinaria Especial", sin login en demo |
| Identidad seed | SOUL.md, AGENTS.md, MEMORY.md (persona OT en español) |
| 6 skills | rfq→oferta, memoria proyectos, checklist cierre, cálculo margen, sección técnica, validar plazo |
| Corpus | 14 docs en `seed/company-docs/` (ficticios), AC-2024-017 como proyecto faro |
| Runbook + demo | Operación y guion de venta (RFQ por la GUI) |

## Responsabilidades del cliente

1. Aportar credenciales LLM vía `make setup` (la key queda en su volumen, no en git).
2. Antes de producción: activar login de la GUI (`WEBUI_AUTH=true`), VPN/SSO/TLS, rotar `API_SERVER_KEY`.
3. Revisión humana de cada borrador antes de enviarlo al cliente (gobernanza en SOUL.md).

## Palancas de personalización

- **Persona:** `seed/SOUL.md` → reseed.
- **Tarifas / plantilla:** `seed/company-docs/` (mount ro, sin rebuild).
- **Skills:** `seed/skills/*/SKILL.md`.
- **Marca GUI:** `WEBUI_NAME` en `docker-compose.yml`; tema del agente en `seed/dashboard-themes/acme.yaml`.

## Nota de licencias (importante)

- **Agente Hermes:** MIT (Nous Research). El fork es una capa de parche de marca; ver `HANDOFF.md`.
- **Open WebUI (GUI):** licencia BSD-3 con cláusula de marca. Permite white-label del nombre visible (`WEBUI_NAME`) para despliegues **≤50 usuarios**. Para retirar el 100% de la atribución a mayor escala: **licencia enterprise de Open WebUI** o migrar a **LibreChat (MIT)**, que también habla con el endpoint OpenAI del agente. El modal de "novedades" de primer arranque muestra texto upstream una sola vez (atribución OSS) y se descarta.

## Fuera de alcance (upsell)

- Conectores ERP/MCP. Pipeline RAG. Multi-tenant. Generación de PDF firmado.

## Soporte (demo)

Cliente IT corre Docker en host Linux/Mac; OT de Acme posee el contenido en `seed/`.
