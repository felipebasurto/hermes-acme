# Handoff — Acme Agent v5

## Entrega

Acme Agent v5 queda listo como demo cliente: UI industrial en español, dos perfiles, RBAC frontend/backend, documentación RFQ y video.

## Video

```text
/opt/cursor/artifacts/acme-v5-demo-admin-usuario-20260616-v2.mp4
```

El video es un MP4 1080p con subtítulos en español. Duración aproximada: 3:10.

## Credenciales demo

| Perfil | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin` | `acme-admin-demo` |
| Operador | `operador` | `acme-user-demo` |

## Matriz Admin vs Usuario

| Superficie | Admin | Usuario |
|---|---:|---:|
| Conversación | Sí | Sí |
| Documentación `/workspace/docs` | Sí | Sí, solo lectura |
| Procedimientos | Sí | No |
| Memoria | Sí | No |
| Tareas / Kanban / Lista actual | Sí | No |
| Perfiles | Sí | No |
| Registros | Sí | No |
| Indicadores | Sí | No |
| Configuración | Sí completa | No visible / 403 |
| Proveedor/modelo/API keys/plugins/shutdown | Sí | No visible / 403 |
| Dashboard Hermes externo | No visible | No visible |

## Implementación

Archivos clave:

- `scripts/patch-webui-acme.sh` — palanca v5: branding + RBAC + i18n + tema.
- `docker/webui/acme-industrial.css` — tema industrial de la GUI cliente.
- `seed/acme-ui-config.yaml` — data shape de roles/superficies.
- `scripts/verify-branding.sh` — verificación de marca con login admin.
- `scripts/verify-spanish.sh` — verificación de español visible.
- `docker/webui/Dockerfile` — aplica patch Acme durante build.
- `docker-compose.yml` — env demo login + locale + workspace.

## Verificación

```text
$ ./scripts/verify-branding.sh
== ALL PASS ==

$ ./scripts/verify-spanish.sh
== ALL PASS ==
```

RBAC API:

```text
admin_status=admin
user_status=usuario
user_workspaces=/workspace/docs
user_settings_post=403
user_logs=403
admin_settings=200
admin_profiles=200
admin_logs=200
```

## LLM

No hay proveedor LLM configurado en el repo. La demo muestra el estado esperado:

```text
Modelo no configurado. Ejecute make setup / make setup-portal para configuración inicial.
```

Para respuestas reales:

```bash
make setup
```

## Estado operativo

```text
acme-agent  Up
acme-webui  Up (healthy)
```

URL: `http://localhost:8787/login`

## Commit

HEAD en `main` tras consolidación v5:

```text
e4ea3d0  Merge PR #4 — Acme v5 (UI industrial, RBAC, español)
```

Video demo (Cloud Agent, no está en el repo):

```text
/opt/cursor/artifacts/acme-v5-demo-admin-usuario-20260616-v2.mp4
```
