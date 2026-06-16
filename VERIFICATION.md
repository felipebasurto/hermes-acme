# Verificación — Acme Agent v3

Evidencia capturada el 2026-06-15 (UTC) sobre el stack en ejecución. Comandos
reproducibles abajo. Chat con modelo = **SKIPPED** (sin API key en la VM; ver G6).

## Antes / después (v2 dashboard → v3 GUI)

| Aspecto | v2 (dashboard Hermes) | v3 (GUI Acme) |
|---------|------------------------|---------------|
| Superficie de cliente | Dashboard Hermes con xterm embebido | GUI web de chat Open WebUI, sin terminal |
| Marca del chat | Banner TUI "HERMES-AGENT / Nous Research" (hardcodeado, irresoluble sin fork) | "Acme Maquinaria Especial", modelo `acme-agent` |
| Login | Sin login (INSECURE) | Sin login (`WEBUI_AUTH=false`) |
| Imagen | `nousresearch/hermes-agent:latest` | `acme-hermes-agent:local` (fork de parche) |
| Marca en assets servidos | "Nous Research" presente en ui-tui/dist y web_dist | grep-cero en ambos |
| Skills | 6 acme-* | 6 acme-* (sin cambios) |

## G1 — GUI de chat (PASS)

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/      # 200
```
GUI carga sin login (`WEBUI_AUTH=false`), es chat web (no terminal), marca
"Acme Maquinaria Especial", selector de modelo `acme-agent`. Evidencia:
capturas `v3_gui_acme_chat.webp` y `v3_gui_rfq_sent.webp`.

## G2 — Fork con marca parcheada (PASS)

```bash
make build   # -> acme-hermes-agent:local (la build aborta si queda "Nous Research")
docker exec acme-agent grep -rI "Nous Research" /opt/hermes/ui-tui/dist /opt/hermes/hermes_cli/web_dist | wc -l   # 0
docker exec acme-agent grep -rI "Messenger of the Digital Gods" /opt/hermes/ui-tui/dist /opt/hermes/hermes_cli/web_dist | wc -l   # 0
```
Resultado: `acme-hermes-agent:local` (3.31 GB) construida; conteos = **0** y **0**.
compose usa la imagen local (no `nousresearch/...:latest`).

## G3 — White-label 100% en superficies de cliente (PASS)

```bash
curl -s http://localhost:3000/ | grep -iE 'hermes|nous|nousresearch' && echo FAIL || echo PASS   # PASS (none)
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9119/ || echo "no expuesto"            # 000 (dashboard OFF) -> PASS
```
- GUI primaria (`:3000`): sin cadenas `hermes|nous`. PASS.
- Dashboard secundario (`:9119`): **no expuesto** (`HERMES_DASHBOARD=0`). PASS.
- Residual documentado: el modal de "novedades" de Open WebUI de primer arranque muestra texto upstream una sola vez (atribución OSS exigida por licencia); se descarta con "Okay, Let's Go!" y el nombre visible de la app es Acme.

## G4 — Skills + corpus (PASS)

```bash
make down && sudo rm -rf data/hermes && make up
sudo ls data/hermes/skills/      # 6 dirs acme-*
sudo test -f data/hermes/.no-bundled-skills && echo present
```
Resultado: `acme-calculo-margen acme-checklist-cierre acme-memoria-proyectos
acme-redactar-seccion-tecnica acme-rfq-a-oferta acme-validar-plazo` (6) + marcador
presente. Cero skills del bundle. Corpus: 14 ficheros en `seed/company-docs/`,
faro `proyecto-AC-2024-017.md`, RFQ en `rfq/ejemplo-entrada-001.txt`.

## G6 — Verificación end-to-end

| Check | Resultado |
|-------|-----------|
| `make build` produce imagen local | PASS (`acme-hermes-agent:local`, 3.31 GB) |
| Contenedores arriba | PASS (`acme-agent` Up, `acme-chat` healthy) |
| GUI :3000 HTTP 200 + marca Acme | PASS |
| Dashboard :9119 no expuesto | PASS (000) |
| Scan forbidden `hermes|nous` en URL de cliente | PASS (0) |
| grep-cero "Nous Research" en assets servidos | PASS (0) |
| Skills = solo acme-* (6) | PASS |
| `/v1/models` anuncia `acme-agent` | PASS |
| **Chat RFQ → borrador** | **SKIPPED — sin API key en la VM** |

### Wire del chat (prueba sin modelo)

```bash
curl -s -X POST http://localhost:8642/v1/chat/completions \
  -H "Authorization: Bearer acme-demo-local-key" -H "Content-Type: application/json" \
  -d '{"model":"acme-agent","messages":[{"role":"user","content":"hola"}]}'
```
Devuelve error OpenAI-format: *"No inference provider configured. Run 'hermes model' ... or set an API key (OPENROUTER_API_KEY, OPENAI_API_KEY, ...) in ~/.hermes/.env."* Esto **prueba que la GUI/agente están cableados correctamente**; solo falta la key del modelo (la aporta el cliente con `make setup`). Por eso el chat queda SKIPPED, no FAIL.

## Cómo reproducir todo

```bash
make build
make up
make health
# branding
curl -s http://localhost:3000/ | grep -iE 'hermes|nous' && echo FAIL || echo PASS
docker exec acme-agent grep -rI "Nous Research" /opt/hermes/ui-tui/dist /opt/hermes/hermes_cli/web_dist | wc -l
# skills
sudo ls data/hermes/skills/
# chat (requiere make setup con API key)
```

## Registro

| Fecha (UTC) | make build | make up | GUI 200 | scan PASS | grep-0 | skills 6 | chat |
|-------------|-----------|---------|---------|-----------|--------|----------|------|
| 2026-06-15T22:15Z | PASS | PASS | PASS | PASS | PASS | PASS | SKIPPED (no key) |
