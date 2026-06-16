# Handoff — Acme Agent v6 (rediseño UX "it just works")

## Entrega

El asistente Acme deja de sentirse "panel de control" y pasa a sentirse "asistente que
funciona", con un lenguaje familiar tipo Claude/Codex. Se mantiene todo el backend de
agente (sesiones, tools, workspace, RBAC) y se simplifica radicalmente la experiencia
visible. El LLM puede seguir sin clave; el chat degrada con un aviso elegante en español.

Para el operador de planta: una sola barra lateral con sus conversaciones, un composer
abajo y un enlace a la documentación. Para el siguiente que mantenga esto: el rail SCADA
desaparece por CSS/HTML en el parche idempotente, no se tocó el stack ni el gateway.

## Qué se simplificó (Subtract Before You Add)

1. **Fuera el rail de 10+ iconos.** Eliminado (`.rail`, `.sidebar-nav` ocultos). La
   navegación vive en un footer del sidebar: `Documentación` (todos) y `Configuración`
   (solo admin). El logo del header vuelve a la conversación.
2. **Chat calmado estilo Claude.** Lienzo oscuro de lectura, columna de mensajes de 760px,
   asistente plano, burbuja de usuario discreta, composer con botón azul (no ámbar), tool
   cards planas con borde ámbar de señal. Caduceo Hermes reemplazado por la marca Acme.
3. **Config escondida, no pestaña gigante.** El admin llega a ajustes en 1 clic desde el
   footer; el operador no ve engranaje (CSS + guarda RBAC backend intacta).

## Video

```text
/opt/cursor/artifacts/acme_v6_claude_like_operador_admin.mp4
```

Recorrido operador (chat limpio + docs + aviso español sin LLM) y admin (footer con
Configuración + settings en español). Revisión: PASS, sin rail, sin inglés, sin glitches.

## Credenciales demo (sin cambios)

| Perfil | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin` | `acme-admin-demo` |
| Operador | `operador` | `acme-user-demo` |

`http://localhost:8787/login`

## Archivos tocados

- `docker/webui/acme-industrial.css` — reescrito hacia calm Claude-like + acentos Acme.
- `scripts/patch-webui-acme.sh` — oculta rail, inyecta footer del sidebar, logo→home,
  marca Acme en empty state, mark cuadrada `favicon-mark.svg`, copy de empty state y más
  overrides es-ES (workspace empty, settings conversation). Idempotente.
- `seed/acme-ui-config.yaml` — v6: layout Claude-like, rail oculto, ancho 272, acciones
  de footer por rol.
- `docs/DESIGN-ACME.md` — CREADO. SSOT visual (atmósfera, color, tipo, layout, anti-patterns).
- `DEMO-SCRIPTS.md` — guion demo 3 min "como Claude pero Acme".
- `VERIFICATION.md` — evidencia post-rediseño.

No se tocó: `docker-compose.yml`, gateway `acme-agent`, skills seed, `company-docs`.

## Matriz Admin vs Operador (frontend; RBAC backend intacto)

| Superficie | Admin | Operador |
|---|---:|---:|
| Conversación (home) | Sí | Sí |
| Documentación `/workspace/docs` | Sí | Sí, solo lectura |
| Configuración | Footer, 1 clic | No visible / 403 |
| Procedimientos / Memoria / Tareas / Perfiles / Registros / Indicadores | En config avanzada | No |
| Rail de iconos | Eliminado | Eliminado |
| Proveedor / modelo / API keys / shutdown | Sí | No visible / 403 |

## Verificación

```text
$ make verify
== ALL PASS ==   # branding
== ALL PASS ==   # español
```

RBAC backend: operador `GET /api/logs` → 403, `POST /api/settings` → 403; admin → 200.

## Tabla taste-skill → decisión concreta

Nota de transparencia: los ficheros `.agents/skills/*/SKILL.md` listados en la misión no
están presentes en este repo (no hay carpeta `.agents/`). Apliqué la intención de cada
skill según el brief de la misión, más los principios de **poteto-mode** (cuyo `SKILL.md`
sí leí). La tabla mapea cada skill a la decisión concreta que dirigió.

| Skill | Decisión concreta que cambió |
|---|---|
| redesign-existing-projects | Fix incremental sobre `acme-industrial.css` + parche, no rewrite. Audité el baseline (rail 2 iconos operador / 10+ admin) antes de tocar nada. |
| design-taste-frontend | Escribí el Design Read de 1 línea (cabecera de `DESIGN-ACME.md`) antes de codear; adapté el anti-slop a agent UI (sin hero, sin landing). |
| minimalist-ui | Referencia de densidad: lienzo calmado `#14171c`, hairlines `#2b333d`, poco chrome, asistente plano. |
| industrial-brutalist-ui | Solo toques Acme: monospace en tool cards, **borde izquierdo 3px ámbar** como señal, acero de fondo. No brutalismo completo. |
| brandkit | Tokens Acme coherentes (acero `#1a1f26`, ámbar `#f59e0b`, azul `#2563eb`); marca triangular derivada de `seed/assets/logo.svg` en header y empty state. |
| stitch-design-taste | Entregable `docs/DESIGN-ACME.md` como SSOT (atmósfera, color, tipo, componentes, anti-patterns). |
| high-end-visual-design | Micro-interacciones: hover/focus/activo a 160ms ease-out, anillo de foco azul, estado disabled del botón enviar. Sin bounce/parallax. |
| gpt-taste | Solo jerarquía tipográfica (15/14/13/12) y spacing generoso entre secciones; ignorado GSAP/AIDA/hero marketing. |
| full-output-enforcement | CSS y parches completos, sin `// ...` ni "resto igual". El parche se ejecuta de principio a fin e idempotente. |
| design-taste-frontend-v1 | Fallback: usado como criterio cuando v2 sonaba demasiado landing; mantuve la lente agent-UI. |
| image-to-code / imagegen-* | Skip: no se generaron mockups; se rediseñó el producto real (verificado en `:8787`). |

## Principios poteto-mode aplicados

- **Subtract Before You Add:** primero borré el rail y la barra de tabs duplicada; luego
  construí el footer mínimo sobre la base ya simplificada.
- **Build the Lever:** todo el rediseño vive en `patch-webui-acme.sh` (idempotente,
  reejecutable por el revisor en `make build`), no en ediciones a mano del clone upstream.
- **Prove It Works:** verificado contra el artefacto real (`make up` + `make verify` +
  recorrido GUI grabado), no contra un proxy.
- **Make Operations Idempotent:** la inyección del footer tiene guarda (`acme-sidebar-foot`
  no duplica); las sustituciones convergen al mismo estado al reejecutar.
- **Never Block on the Human:** decisiones reversibles (ancho 272, fuente IBM Plex Sans)
  tomadas y documentadas en `DESIGN-ACME.md` en vez de preguntar.

## LLM

Sin proveedor en el repo. Con el stack arrancado, el chat responde en español:
"Modelo no configurado…". Para respuestas reales: `make setup`.

## Estado operativo

```text
acme-agent  Up
acme-webui  Up (healthy)
```
