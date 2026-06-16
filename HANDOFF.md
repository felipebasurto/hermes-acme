# Handoff — Acme Agent v3

## Repo / rama

- Remote: https://github.com/felipebasurto/hermes-acme
- Rama de este trabajo: `cursor/acme-agent-v3-f135` (parte de la rama white-label v2).

## Qué se entregó (v3)

Agente Hermes con **GUI web de chat** para el cliente (sin terminal, sin login en demo) y marca upstream eliminada de las superficies de cliente, sin perder capacidades del agente.

- **GUI cliente** `acme-chat` (Open WebUI) en `:3000`, `WEBUI_AUTH=false`, `WEBUI_NAME=Acme Maquinaria Especial`, apuntando al endpoint OpenAI del agente.
- **Agente headless** `acme-agent`: imagen fork `acme-hermes-agent:local`, `HERMES_DASHBOARD=0` (sin TUI/xterm de cara al cliente), API `:8642/v1` OpenAI-compatible, modelo anunciado `acme-agent`.
- **Fork de parche** (`Dockerfile`): reemplaza la marca upstream en los assets servidos del agente; build-time assert de grep-cero.
- **6 skills Acme** (`acme-*`) + marcador `.no-bundled-skills` (sin los ~73 del bundle).
- Docs v3: README (3 pasos GUI), ARCHITECTURE (decisión GUI + mermaid), RUNBOOK, CLIENT-PACK, DEMO-SCRIPTS, VERIFICATION.

## Qué se verificó (evidencia en VERIFICATION.md)

| Goal | Estado |
|------|--------|
| G1 GUI de chat (no terminal), carga 200, sin login | PASS |
| G2 imagen fork local + grep-cero "Nous Research" en assets servidos | PASS |
| G3 scan `hermes|nous` en URL de cliente; dashboard no expuesto | PASS |
| G4 6 skills acme-* + marcador; cero bundle | PASS |
| G5 ops: README/Makefile(build)/RUNBOOK/ARCHITECTURE/CLIENT-PACK + push | PASS |
| G6 infra+branding end-to-end | PASS |
| Chat RFQ → borrador con modelo | **SKIPPED** (sin API key en la VM) |

El wire del chat está probado: `POST /v1/chat/completions` al agente devuelve el error OpenAI-format "No inference provider configured", confirmando GUI↔agente; solo falta la key (cliente, `make setup`).

## Ficheros parcheados por el fork (Dockerfile) y por qué

`sed` sobre frases de texto visible CON ESPACIOS en `/opt/hermes/ui-tui/dist` y `/opt/hermes/hermes_cli/web_dist`:

- `Messenger of the Digital Gods` → `Maquinaria Especial Burgos`
- `Nous Research` → `Acme Maquinaria Especial`
- `Hermes Teal` → `Acme Acero`
- `Hermes Agent` → `Acme Agent`

No se toca `Hermes` a secas (rompería identificadores funcionales como `__HERMES_PLUGIN_SDK__`, `HERMES_DASHBOARD`). El dashboard va desactivado, así que estos assets ni se sirven; el parche es defensa en profundidad y satisface el grep-cero de G2/G6.

## Decisiones clave

- **GUI = Open WebUI** (no LibreChat): único requisito duro de "sin login" lo cumple `WEBUI_AUTH=false`; un solo contenedor (fiabilidad desatendida); wiring OpenAI por env. Tradeoff de licencia en `CLIENT-PACK.md` (≤50 usuarios; a escala, enterprise o LibreChat MIT). Tabla comparativa en `docs/ARCHITECTURE.md`.
- **Agente headless** (dashboard OFF): elimina de raíz el residual del banner TUI de v2 (era irresoluble sin fork) porque el cliente ya no ve esa superficie.
- **Token interno** `API_SERVER_KEY=acme-demo-local-key` en compose: es auth interna GUI↔agente, no una key de LLM. Rotar en prod.

## Qué queda / límites conocidos

- **Chat con modelo: SKIPPED** — requiere `make setup` con API key del cliente (no se pidió, por diseño). Tras configurarla, repetir G6 chat (RFQ → BORRADOR citando AC-2024-017, margen ≥ 18 %).
- **Modal de novedades de Open WebUI** en primer arranque: texto upstream una sola vez (atribución OSS por licencia); se descarta con "Okay, Let's Go!".
- **`<title>` estático** de Open WebUI contiene "Open WebUI" en el HTML servido; el nombre visible renderizado es Acme (`WEBUI_NAME`). Retirarlo del bundle entra en conflicto con la licencia OSS; documentado.
- Open WebUI muestra respuesta vacía (no error verboso) cuando el agente devuelve error sin modelo; con modelo configurado responde normal.

## Reproducir

```bash
make build && make up           # construye fork + arranca GUI y agente
make health                     # GUI :3000, API :8642, skills
open http://localhost:3000      # GUI Acme, sin login
make setup                      # (cliente) API key del modelo -> data/hermes/.env
# verificación de marca:
curl -s http://localhost:3000/ | grep -iE 'hermes|nous' && echo FAIL || echo PASS
docker exec acme-agent grep -rI "Nous Research" /opt/hermes/ui-tui/dist /opt/hermes/hermes_cli/web_dist | wc -l   # 0
sudo ls data/hermes/skills/     # 6 acme-*
```

## No está en git

- `data/hermes/.env` (API key del modelo), `data/hermes/sessions/`, `data/hermes/` y `data/open-webui/` (runtime).

## Anti-patterns evitados

- GUI web, no terminal, como superficie de cliente. Imagen local (no `nousresearch/...:latest`) en compose. Sin secrets de LLM en git. Sin sync de los 73 skills del bundle. Sin marcar goals done sin output de verificación.
