# Verificación — Acme Hermes (white-label v2)

Ejecutar desde la raíz tras `make up`. Demo **sin login**.

## Antes / después (white-label)

| Aspecto | Antes (Hermes/Nous) | Después (Acme) |
|---------|---------------------|----------------|
| Login | Basic auth `acme`/`changeme` | Sin login (demo LAN, `INSECURE=1`) |
| Marca cabecera | Wordmark "Hermes Agent" | Logo Acme + "MAQUINARIA ESPECIAL · BURGOS" |
| Pie barra lateral | Enlace "Nous Research" | Oculto (cero Nous visible) |
| Selector de temas | Visible (Hermes Teal, Nous Blue, …) | Oculto; tema `acme` único/activo |
| Navegación | ~19 pestañas (Models, Logs, Cron, MCP, Kanban, …) | Chat, Sesiones, Skills, Docs, Config |
| Sección "Plugins" | Achievements, Kanban | Oculta |
| Skills | ~73 del bundle + 3 Acme | Solo 3 Acme |
| Título/favicon navegador | "Hermes Agent - Dashboard" / favicon Hermes | "Acme Maquinaria Especial — Panel" / favicon Acme |
| Banner API server | "Api_server disconnected" (rojo) | Sin banner (API off hasta `make setup`) |

## Infra y white-label (sin API key)

```bash
# Panel sin login (espera 200, no 302):
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9119/                 # 200

# Auth desactivada:
curl -s http://localhost:9119/api/status | python3 -m json.tool                 # auth_required:false, auth_providers:[]

# Tema Acme activo:
curl -s http://localhost:9119/api/dashboard/themes | python3 -c \
  "import sys,json;print(json.load(sys.stdin)['active'])"                        # acme

# Plugin acme-admin descubierto (source user):
curl -s http://localhost:9119/api/dashboard/plugins                             # incluye {"name":"acme-admin","source":"user"}

# Logo Acme servido (ruta de assets de plugin):
curl -s -o /dev/null -w "%{http_code} %{content_type}\n" \
  http://localhost:9119/dashboard-plugins/acme-admin/dist/logo.svg              # 200 image/svg+xml

# Solo skills Acme en el volumen:
ls data/hermes/skills/                                                          # acme-checklist-cierre / acme-memoria-proyectos / acme-rfq-a-oferta
ls data/hermes/.no-bundled-skills                                               # marcador presente

# Corpus montado (solo lectura):
make shell  # -> ls /workspace/docs   (14 ficheros)
```

Resultados de referencia (capturados en este despliegue): `GET / → 200`;
`auth_required:false`, `auth_providers:[]`, `gateway_platforms:[]`;
`themes.active = acme`; plugins = `acme-admin (user)`, achievements/kanban (bundled, pestañas ocultas);
skills = solo las 3 Acme.

## Prueba de chat / RFQ (requiere modelo)

El chat acepta y **encola** el mensaje sin modelo, mostrando
"Setup Required — Hermes needs a model provider". Tras `make setup` (key del
cliente en `data/hermes/.env`):

1. Abrir http://localhost:9119 → Chat.
2. Pegar la RFQ de `seed/company-docs/rfq/ejemplo-entrada-001.txt`.
3. Esperar **BORRADOR** con referencia AC, cita de `AC-2024-017`, secciones de la plantilla v3 y margen ≥ 18 %.

> Sin key no se genera el borrador (es acción del cliente: `make setup`). Todo lo demás se verifica arriba sin key.

## Registro de evidencia

| Fecha | Operador | make up | sin login | tema acme | solo skills Acme | chat RFQ (tras setup) |
|-------|----------|---------|-----------|-----------|------------------|------------------------|
| | | | | | | |
