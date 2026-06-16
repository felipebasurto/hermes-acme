# AGENTS — despliegue Acme Hermes (v5)

Repo de referencia Docker para **Acme Maquinaria Especial** (ficticio, Burgos).
Fork white-label de `nousresearch/hermes-agent` + GUI `hermes-webui` parcheada.
Sin npm/cargo/tests. Artefactos: Compose, `seed/`, scripts, Dockerfiles.

## Comandos

```bash
make build && make up && make verify
```

GUI: **http://localhost:8787/login**

| Perfil | Usuario | Contraseña |
|--------|---------|------------|
| Administrador | `admin` | `acme-admin-demo` |
| Operador | `operador` | `acme-user-demo` |

Docs: `README.md`, `HANDOFF.md`, `docs/RUNBOOK.md`, `VERIFICATION.md`.

## Stack v5

- `acme-agent` — gateway Hermes, `HERMES_DASHBOARD=0`, API `:8642`
- `acme-webui` — UI industrial español + RBAC, `:8787`
- Volumen compartido `./data/hermes`
- Corpus `./seed/company-docs` → `/workspace/docs` (ro, bind mount; no copiar al volumen)

## Parches WebUI (Build the Lever)

1. `scripts/patch-webui-branding.sh` — marca Acme, grep-cero nous en static/
2. `scripts/patch-webui-acme.sh` — v5: RBAC, es-ES, CSS industrial, auth demo

Aplicados en build vía `docker/webui/Dockerfile`. Config roles: `seed/acme-ui-config.yaml`.

## Verificación

```bash
make verify          # branding + español
./scripts/healthcheck.sh
```

## Cursor Cloud / VM

Docker daemon no auto-arranca. Iniciar `dockerd` y socket accesible antes de `make up`.

Usar Compose v2:

```bash
make up DOCKER_COMPOSE="docker compose"
```

## LLM

Sin proveedor en repo. Chat muestra error de modelo hasta `make setup` (escribe `data/hermes/.env`).

## Reseed

`scripts/seed-volume.sh` rsync `seed/` → `data/hermes/` (excluye `.env` y `company-docs/`).
No sobrescribe keys LLM. Sincroniza `API_SERVER_KEY` con compose.

Reseed limpio:

```bash
make down && rm -rf data/hermes && make up
```

## Anti-patterns

- No reintroducir Open WebUI ni dashboard `:9119`
- No editar parches a mano en el clone upstream; usar scripts idempotentes
- No commitear `data/hermes/`
