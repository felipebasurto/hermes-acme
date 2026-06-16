# Runbook — Acme Agent v5

## Prerrequisitos

- Docker Engine + Compose v2.
- Puertos libres:
  - `8787` — UI Acme.
  - `8642` — API/gateway del agente.

En Cursor Cloud, si Docker no está iniciado:

```bash
sudo dockerd
sudo chmod 666 /var/run/docker.sock
```

## Arranque

```bash
make build
make up
```

Abrir: **http://localhost:8787/login**

Credenciales demo:

| Perfil | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin` | `acme-admin-demo` |
| Operador | `operador` | `acme-user-demo` |

## Verificación

```bash
docker compose ps
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8787/login
./scripts/verify-branding.sh
./scripts/verify-spanish.sh
```

Salida esperada de los scripts:

```text
== ALL PASS ==
```

## Roles

### Administrador

Puede ver y usar:

- Conversación
- Documentación
- Procedimientos
- Memoria
- Tareas / Kanban / Lista actual
- Perfiles
- Registros
- Indicadores
- Configuración completa

### Operador

Puede ver:

- Conversación
- Documentación (`/workspace/docs`, solo lectura)

No debe ver ni usar:

- Configuración
- Proveedor/modelos/API keys
- Procedimientos
- Memoria
- Registros
- Perfiles
- Plugins
- Shutdown/gateway avanzado

## Checks RBAC rápidos

```bash
ADMIN_COOKIE="$(mktemp)"
USER_COOKIE="$(mktemp)"

curl -s -c "$ADMIN_COOKIE" -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"acme-admin-demo"}' \
  http://localhost:8787/api/auth/login

curl -s -c "$USER_COOKIE" -H 'Content-Type: application/json' \
  -d '{"username":"operador","password":"acme-user-demo"}' \
  http://localhost:8787/api/auth/login

curl -s -b "$USER_COOKIE" http://localhost:8787/api/workspaces
curl -s -o /dev/null -w "%{http_code}\n" -b "$USER_COOKIE" http://localhost:8787/api/logs
```

Esperado:

- Workspaces operador: solo `/workspace/docs`.
- Logs operador: `403`.

## Configurar modelo LLM

La demo UI funciona sin LLM. Para respuestas reales:

```bash
make setup
```

Esto escribe claves en `data/hermes/.env` (gitignored). El repo no contiene claves reales.

## Reseed / reset

Si `data/hermes` quedó con permisos de contenedor:

```bash
make down
sudo rm -rf data/hermes
make up
```

## Logs

```bash
make logs-webui
make logs-agent
```

No parar contenedores al terminar una demo salvo que se necesite reset explícito.
