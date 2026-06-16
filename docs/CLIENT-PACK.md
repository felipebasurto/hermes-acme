# Client pack — Acme Agent v4

Workspace empaquetado para **Acme Maquinaria Especial** (demo/mock).

## Incluido

| Entregable | Descripción |
|------------|-------------|
| Stack two-container | `acme-webui` + `acme-agent` |
| GUI agente | Fork MIT [hermes-webui-acme](https://github.com/felipebasurto/hermes-webui-acme) (build vía `docker/webui/Dockerfile`) |
| Agente fork | `acme-hermes-agent:local` con parche de marca en assets servidos |
| Identidad | SOUL.md, AGENTS.md, MEMORY.md |
| 8 skills | 6 originales + export PDF + escalada María |
| Corpus | 14 docs ficticios, AC-2024-017 |
| Verificación | `scripts/verify-branding.sh`, `VERIFICATION.md` |

## Responsabilidades del cliente

1. Credenciales LLM vía `make setup`.
2. Producción: password webui, VPN/TLS, rotar tokens internos.
3. Revisión humana de cada BORRADOR (SOUL.md).

## Personalización

- Persona y skills: `seed/` → reseed.
- Marca GUI: `scripts/patch-webui-branding.sh` + rebuild webui.
- Tema industrial: paleta en `seed/dashboard-themes/acme.yaml`.

## Licencias

- **Hermes Agent:** MIT (Nous Research). Fork de parche en `Dockerfile`.
- **Hermes WebUI (GUI):** MIT upstream (nesquena/hermes-webui). Fork Acme sin cláusula de marca Open WebUI. Sin modal de novedades OSS del chatbot anterior.

## Fuera de alcance

ERP/MCP, RAG, multi-tenant, envío automático al cliente final.
