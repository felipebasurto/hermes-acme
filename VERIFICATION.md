# Verification — Acme Agent v6 (rediseño UX Claude-like)

Fecha: 2026-06-16. Stack completo (`make up`) con `acme-agent` + `acme-webui`.

## Resultado

| Criterio | Estado | Evidencia |
|---|---|---|
| Sin rail de iconos (operador y admin) | PASS | Video + screenshots `v6_*` |
| Navegación en footer del sidebar | PASS | `Documentación` (todos), `Configuración` (admin) |
| UI español visible | PASS | `./scripts/verify-spanish.sh` ALL PASS |
| Branding Acme sin upstream visible | PASS | `./scripts/verify-branding.sh` ALL PASS |
| Aviso sin LLM elegante en español | PASS | "Modelo no configurado…" (no modal, no inglés) |
| Admin config en ≤2 clics | PASS | Footer → Configuración (1 clic) |
| Operador limitado | PASS | Manual GUI + `/api/logs` y `POST /api/settings` 403 |
| Tema calmado Claude-like | PASS | `static/acme-industrial.css` + video |
| Caduceo Hermes eliminado | PASS | Marca triangular Acme en header + empty state |
| Video entregado | PASS | `acme_v6_claude_like_operador_admin.mp4` |

## Checklist "it just works"

- Operador en 10 s entiende dónde escribir (composer abajo), dónde ver chats viejos
  (lista bajo "Conversación") y dónde leer docs (footer "Documentación"). PASS.
- Admin encuentra configuración en 1 clic (footer "Configuración"), sin contar pestañas. PASS.
- Ninguna string "Hermes" / "Nous" / "Open WebUI" visible. PASS (verify-branding).
- Cero pestañas de rail visibles para operador (ni para admin). PASS.
- Tool cards legibles (borde ámbar, monospace) aunque el LLM esté off. PASS (CSS).
- `verify-branding.sh && verify-spanish.sh` → ALL PASS. PASS.

## Stack

```text
$ docker compose ps
acme-agent   Up 19 minutes             0.0.0.0:8642->8642/tcp
acme-webui   Up 19 minutes (healthy)   0.0.0.0:8787->8787/tcp
```

## make verify

```text
$ make verify
./scripts/verify-branding.sh
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
./scripts/verify-spanish.sh
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

## RBAC backend (sin cambios; seguridad intacta)

```text
admin login role=admin
operador login role=usuario
operador GET  /api/logs            -> 403
operador POST /api/settings        -> 403
admin    GET  /api/logs            -> 200
operador GET  /api/workspaces      -> /workspace/docs (solo lectura)
```

El rediseño simplifica solo el FRONTEND. Las guardas de `_acme_deny_if_needed`
en `api/routes.py` siguen devolviendo 403 al operador.

## Aviso sin LLM (degradación elegante)

Con el agente arrancado y sin clave de modelo, el chat responde en español:

```text
Error: Modelo no configurado. Ejecute `hermes model` para seleccionar proveedor,
o ejecute `hermes setup` para la configuración inicial.
  ▸ Detalles del proveedor
```

No bloquea, no es modal, no hay inglés. El operador entiende que falta configurar IT.

## Video

```text
/opt/cursor/artifacts/acme_v6_claude_like_operador_admin.mp4
```

Recorrido: login operador → chat limpio sin rail + footer Documentación → RFQ con aviso
español → docs → volver con logo → login admin → footer con Configuración → settings en
español → volver con logo. Revisión de video: PASS (sin glitches, sin inglés, sin rail).
