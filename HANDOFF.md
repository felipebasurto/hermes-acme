# Handoff — Acme Hermes (white-label v2)

## Repo

- **Remote:** https://github.com/felipebasurto/hermes-acme
- **Propósito:** despliegue Docker white-label del Hermes Agent para Acme Maquinaria Especial (ficticio). Panel administrativo simplificado, marca Acme, sin login en demo. Capacidades del agente intactas (RFQ → borrador).

## Qué se construyó (v2)

- `docker-compose.yml`: sin `HERMES_DASHBOARD_BASIC_AUTH_*`, con `HERMES_DASHBOARD_INSECURE=1` (demo sin login) y `API_SERVER_ENABLED=false` (gateway REST opcional, sin banner de error).
- `seed/dashboard-themes/acme.yaml`: tema Acme completo (paleta, tipografía IBM Plex, logo, `colorOverrides`) + `customCSS` que sustituye el wordmark por el logo Acme, oculta el selector de temas, el enlace Nous, la sección "Plugins" y las pestañas avanzadas.
- `seed/plugins/acme-admin/`: plugin UI slot-only (`tab.hidden`) que fija `document.title` y el favicon Acme (lo que el CSS no puede), y sirve el logo (`dist/logo.svg`).
- `seed/.no-bundled-skills`: marcador que deja **solo** los 3 skills Acme.

## Decisiones y tradeoffs

### Por qué `INSECURE` (sin login)
El gate de auth de Hermes solo se activa si hay un proveedor registrado (`BASIC_AUTH_*`, OAuth, OIDC). Sin proveedor y con bind a `0.0.0.0`, Hermes exige `--insecure` (`HERMES_DASHBOARD_INSECURE=1`) o falla cerrado. Es el camino soportado para una demo LAN sin login. **En producción** va detrás de VPN/SSO/reverse proxy o el OAuth/OIDC de Hermes (ver `docs/RUNBOOK.md`).

### Cómo se oculta lo que no debe verse (tradeoff principal)
Hermes soporta **añadir** pestañas/slots y **sobrescribir** páginas vía plugins, pero **no** expone una API para **ocultar pestañas built-in** ni el selector de temas. El único mecanismo sin fork es el `customCSS` del tema con selectores del DOM real (`#app-sidebar`, `nav[aria-label="Navigation"] a[href="/…"]`, `button[aria-label="Switch theme"]`, `a[href*="nousresearch.com"]`, `div[aria-labelledby="hermes-sidebar-plugin-nav-heading"]`).

**Riesgo:** si una futura imagen de Hermes cambia el marcado del shell, estos selectores hay que reajustarlos. Es un tradeoff aceptado para cumplir "sin fork". Los elementos siguen en el DOM (ocultos con `display:none`), no eliminados — "cero strings Nous **visibles**", no borrados del bundle.

### Capacidades intactas (no se desactivan toolsets)
La misión pedía "desactivar toolsets/features no necesarios" pero también "mantener TODAS las capacidades del agente". Gana la restricción dura: **no** se tocan los toolsets del agente (podrían romper el flujo RFQ→oferta). Se simplifica **solo lo visible** (navegación). 

### Pestañas que quedan
Chat, Sesiones, Skills, Docs (Documentation), Config. Se ocultan: Files, Models, Logs, Cron, Plugins, MCP, Channels, Webhooks, Pairing, Profiles, Env (Keys), System(nav), Kanban, Achievements, Analytics. Para mostrar/ocultar otra, edita la lista de selectores en `acme.yaml`.

### Skills curados
`seed/.no-bundled-skills` hace que `tools/skills_sync.py` del contenedor sea no-op (deja solo `seed/skills/`). En un volumen ya poblado con el bundle: `make down && rm -rf data/hermes && make up`.

### Logo: ruta de servido (gotcha)
`/dashboard-themes/assets/` **no** se sirve (cae al index.html de la SPA). La única ruta de ficheros estáticos es la de assets de plugin: el logo se sirve por `/dashboard-plugins/acme-admin/dist/logo.svg` y se referencia así desde el `customCSS`.

### Residuales conocidos (límites del "sin fork")

1. **Banner del chat embebido (el más relevante).** El chat es un terminal xterm.js que ejecuta la TUI del agente. Su splash de inicio muestra el arte ASCII "HERMES-AGENT" y la línea "Nous Research · Messenger of the Digital Gods". Investigado a fondo: esa línea es una **constante hardcodeada** en `ui-tui/src/components/branding.tsx` (`TAG_FULL`), y el arte grande usa el `bannerLogo` por defecto. Ni los temas/plugins del dashboard ni el sistema de skins de la CLI (`~/.hermes/skins/*.yaml`, `display.skin`) pueden quitarlos: el skin recolorea y cambia `agent_name` (solo visible en modo compacto/status), pero no el arte ancho ni el tagline. Quitarlos exige **forkear** la TUI/imagen, prohibido por las restricciones. Atenuante: el banner es del estado inactivo/"setup required"; al iniciar conversación (tras `make setup`) el borrador llena el terminal y el banner sube fuera de vista. Es texto de celdas de terminal, no DOM, así que tampoco es ocultable por CSS de forma fiable.

2. **Pie "System"** ("Update Hermes" / "Restart Gateway"): controles operativos. No contienen "Nous" ni "Hermes Teal" (lo que prohíbe el DoD), se dejan por utilidad. Para ocultarlos, añadir un selector de la sección System en `acme.yaml`.

El shell del dashboard (barra lateral, navegación, cabecera, título, favicon, temas, skills) — lo que ve el admin la mayor parte del tiempo — sí queda 100% white-label por mecanismos soportados.

## Re-brand para otro cliente

1. `seed/dashboard-themes/acme.yaml`: cambia `palette`/`colorOverrides`/`assets`, y dentro de `customCSS` el `url(...)` del logo y, si hace falta, los selectores.
2. `seed/plugins/acme-admin/dashboard/dist/logo.svg`: nuevo logotipo.
3. `seed/plugins/acme-admin/dashboard/dist/index.js`: `BRAND` (título) y `FAVICON`.
4. `seed/SOUL.md`, `seed/AGENTS.md`, `seed/company-docs/`: persona y corpus del cliente.
5. `seed/config.yaml`: `dashboard.theme` apunta al nombre del tema.

## No está en git

- `data/hermes/.env` — API keys (las pone el cliente en `make setup`).
- `data/hermes/sessions/` — sesiones runtime.

## Anti-patterns evitados

- Sin API keys en repo/seed. Sin fork de hermes-agent ni de la imagen. Sin React custom fuera del mecanismo de plugins. Sin auto-envío de ofertas (gobernanza BORRADOR en `seed/SOUL.md`).
