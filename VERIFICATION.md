# Verification — Acme Agent v5

Fecha: 2026-06-16.

## Resultado

| Criterio | Estado | Evidencia |
|---|---|---|
| UI español visible | PASS | `./scripts/verify-spanish.sh` |
| Branding Acme sin upstream visible | PASS | `./scripts/verify-branding.sh` |
| Admin con configuración completa | PASS | Manual GUI + API admin 200 |
| Operador limitado | PASS | Manual GUI + `/api/logs` 403 |
| Tema industrial | PASS | `static/acme-industrial.css` + video |
| RFQ demo documentada | PASS | `DEMO-SCRIPTS.md` |
| Video entregado | PASS | `/opt/cursor/artifacts/acme-v5-demo-admin-usuario-20260616-v2.mp4` |

## Stack

```text
$ docker compose ps
NAME         STATUS                   PORTS
acme-agent   Up 2 hours               0.0.0.0:8642->8642/tcp, [::]:8642->8642/tcp
acme-webui   Up 2 minutes (healthy)   0.0.0.0:8787->8787/tcp, [::]:8787->8787/tcp
```

## Branding

```text
$ ./scripts/verify-branding.sh
== Branding verify @ http://localhost:8787 ==
PASS [login] login page reachable
PASS [auth] admin login role=admin
PASS [index.html] no forbidden: hermes web|hermes control|open webui|nousresearch|nous research
PASS [index.html-title] no forbidden: <title>[^<]*(hermes|nous|open webui)
PASS [index.html] Acme title present
PASS [index.html] industrial stylesheet referenced
PASS [auth/status] Acme admin role present
PASS [manifest.json] no forbidden: hermes|nous|open webui
PASS [manifest.json] Acme name present
PASS [favicon.svg] Acme logo marker present
PASS [ui.js] no forbidden: nousresearch|nous research|hermes web ui|hermes control center|open webui
PASS [panels.js] no forbidden: nousresearch|nous research|hermes web ui|hermes control center|open webui
PASS [boot.js] no forbidden: nousresearch|nous research|hermes web ui|hermes control center|open webui
PASS [acme-industrial.css] Acme steel token present
== ALL PASS ==
```

## Español

```text
$ ./scripts/verify-spanish.sh
== Spanish verify @ http://localhost:8787 ==
PASS [login] contiene: Acceso al asistente de ofertas
PASS [login] contiene: Usuario
PASS [login] contiene: Contraseña demo
PASS [login] sin inglés visible: Sign in|Enter your password|Invalid password|Connection failed
PASS [auth] login admin correcto
PASS [index] contiene: Acme Maquinaria Especial
PASS [index] contiene: Conversación
PASS [index] contiene: Documentación
PASS [index] contiene: Procedimientos
PASS [index] contiene: Configuración
PASS [index] contiene: Escribe tu consulta de oferta
PASS [index] sin inglés visible: Welcome to|Message Hermes|Filter conversations|New conversation|Search skills
PASS [i18n] contiene: tab_chat: 'Conversación'
PASS [i18n] contiene: tab_settings: 'Configuración'
PASS [i18n] contiene: providers_section_title: 'Proveedor de modelo'
PASS [i18n] contiene: Documentación Acme
PASS [i18n-acme-overrides] sin inglés visible: TODO: translate|Session Toolsets|Welcome to Hermes Web UI|Search known tools across
PASS [panels] contiene: Acceso reservado a administrador
PASS [panels] contiene: Documentación Acme — solo lectura
PASS [panels] sin inglés visible: Hermes Web UI|Hermes Control Center|Open WebUI
PASS [boot] contiene: Acme Industrial
PASS [boot] contiene: skin:'acme-industrial'
PASS [boot] sin inglés visible: Message '\+name
== ALL PASS ==
```

## RBAC API

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

## Manual GUI

Manual testing confirmed:

- Login page español e industrial.
- Admin shows `ADMINISTRADOR`, full rail and Configuración.
- Operador shows `OPERADOR`, only Conversación + Documentación.
- `/api/logs` as operador returns `{"error":"Acceso reservado a administrador","acme_role":"usuario"}`.

## Video

Archivo final:

```text
/opt/cursor/artifacts/acme-v5-demo-admin-usuario-20260616-v2.mp4
```

Revisión de video: PASS. El video muestra login, admin completo, settings, RFQ con modelo no configurado, operador reducido, 403 y cierre en español.
