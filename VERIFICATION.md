# Verification — Acme Agent v4

Fecha: 2026-06-16. Evidencia de comandos ejecutados en host local (Docker OrbStack).

## Cambio v3 → v4

| Aspecto | v3 | v4 |
|---------|----|----|
| GUI | Open WebUI chatbot :3000 | hermes-webui fork agent-native :8787 |
| Wiring | OpenAI shim `/v1/chat/completions` | Gateway compartiendo `data/hermes` |
| Licencia GUI | BSD-3 + cláusula marca | MIT fork |
| Skills | 6 acme-* | 8 acme-* |

## Definition of DONE

| # | Criterio | Estado | Evidencia |
|---|----------|--------|-----------|
| 1 | Open WebUI eliminado | **PASS** | `grep -ri open-webui docker-compose.yml README.md` → vacío |
| 2 | acme-webui build + run | **PASS** | `docker images acme-hermes-webui:local`; compose ps Up healthy |
| 3 | GUI agent-native | **PASS** | hermes-webui: sesiones, workspace mount, skills seed; no shim OpenAI como UX |
| 4 | Forbidden brand absent :8787 | **PASS** | `./scripts/verify-branding.sh` → ALL PASS (output abajo) |
| 5 | 6+ acme skills, no bundle | **PASS** | `ls data/hermes/skills \| grep acme \| wc -l` → 8 |
| 6 | RFQ demo documentado | **PASS** | DEMO-SCRIPTS.md Script C actualizado para :8787 |
| 7 | HANDOFF v4 + push | **PENDING** | commit local; push en curso |

## Comandos de verificación

### Stack (SUBTASK C)

```
$ docker compose ps
NAME         IMAGE                     STATUS
acme-agent   acme-hermes-agent:local   Up
acme-webui   acme-hermes-webui:local   Up (healthy)

$ curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8787/
200

$ grep -ri open-webui docker-compose.yml README.md && echo FAIL || echo PASS
PASS
```

### Branding (SUBTASK D)

```
$ ./scripts/verify-branding.sh
== Branding verify @ http://localhost:8787 ==
PASS [index.html] no forbidden: hermes web|hermes control|open webui|nousresearch|nous research
PASS [index.html-title] no forbidden: <title>[^<]*(hermes|nous|open webui)
PASS [index.html] Acme title present
PASS [manifest.json] no forbidden: hermes|nous|open webui
PASS [manifest.json] Acme name present
PASS [favicon.svg] Acme logo marker present
PASS [ui.js] no forbidden: ...
PASS [panels.js] no forbidden: ...
PASS [boot.js] no forbidden: ...
== ALL PASS ==
```

### Build assert webui (SUBTASK B)

```
$ docker run --rm acme-hermes-webui:local sh -c "grep -riE 'nousresearch|Nous Research' static/ | wc -l"
0
```

### Skills (SUBTASK E)

```
$ ls data/hermes/skills/ | grep acme | wc -l
8
```

### E2E chat (SUBTASK F)

```
$ curl -s -H "Authorization: Bearer acme-demo-local-key" http://localhost:8642/v1/models
{"object":"list","data":[{"id":"acme-agent",...}]}

$ curl -s -X POST .../v1/chat/completions -d '{"model":"acme-agent","messages":[...]}'
{"error":{"message":"...No inference provider configured..."}}
```

**Estado chat RFQ con LLM:** **SKIPPED** (sin API key en VM). Infra + branding PASS.

Manual checklist GUI (http://localhost:8787):

- [x] Carga 200, título Acme
- [x] Sidebar sesiones visible
- [x] Workspace `/workspace/docs` montado (company-docs)
- [x] Sin strings forbidden en verify-branding
- [ ] RFQ → BORRADOR con modelo (requiere `make setup`)

### Onboarding

Primer arranque puede mostrar wizard de configuración upstream. Copy parcheado a Acme en build. Completar wizard una vez; no re-aparece en mismo `data/hermes/webui/`.
