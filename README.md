# Acme Agent — despliegue de referencia (v5)

Agente de oficina técnica para **Acme Maquinaria Especial S.L.** (cliente industrial ficticio, Burgos). Convierte RFQ en **borrador de oferta técnica** desde una GUI de agente industrial en español.

## Qué cambia en v5

- UI cliente `acme-webui` en **http://localhost:8787** con tema **Acme Industrial**.
- Login demo con dos perfiles:
  - `admin` / `acme-admin-demo`
  - `operador` / `acme-user-demo`
- **Administrador:** configuración completa, procedimientos, memoria, tareas, perfiles, registros y proveedor de modelo.
- **Operador:** solo **Conversación** + **Documentación** (`/workspace/docs`, solo lectura).
- Español forzado (`es-ES`) y tema dark único.

> Sin proveedor LLM configurado, el chat puede mostrar “No inference provider configured”. Esto no bloquea la demo de UI/roles/documentación. El administrador configura el modelo en Configuración → Proveedor o con `make setup`.

## Quick start

```bash
make build
make up
make verify
```

Abre **http://localhost:8787/login**.

## Arquitectura

```
navegador ──> acme-webui (:8787, UI industrial + RBAC)
                  │
                  ▼
              acme-agent (gateway Hermes headless)
                  │
                  ▼
              data/hermes + seed/company-docs (/workspace/docs ro)
```

## Comandos

| Comando | Uso |
|---|---|
| `make build` | Construye `acme-hermes-agent:local` y `acme-hermes-webui:local` |
| `make up` | Siembra `seed/` y arranca los contenedores |
| `make down` | Para el stack |
| `make setup` | Configura credenciales reales de proveedor LLM |
| `make verify` | Ejecuta branding + español |
| `./scripts/verify-branding.sh` | Verifica marca Acme servida |
| `./scripts/verify-spanish.sh` | Verifica superficies visibles en español |

## Entregables cliente

- `DEMO-SCRIPTS.md` — guion v5 de demo en español.
- `docs/RUNBOOK.md` — operación y troubleshooting.
- `docs/ARCHITECTURE.md` — contrato de roles/superficies.
- `VERIFICATION.md` — evidencia de build, RBAC y verificación.
- `HANDOFF.md` — entrega final + referencia al video.

## Seguridad

Las contraseñas incluidas son **solo demo local**. En producción: VPN/TLS, rotar tokens internos, definir contraseña real y configurar proveedor LLM fuera del repo (`data/hermes/.env`, gitignored).
