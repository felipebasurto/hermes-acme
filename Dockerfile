# Acme white-label fork de Hermes Agent (capa de parche minima, sin rebuild de fuente).
#
# Construye acme-hermes-agent:local a partir de la imagen oficial y reemplaza las
# cadenas de marca upstream en los ASSETS SERVIDOS al usuario (SPA del dashboard y
# bundle de la TUI embebida). Solo se tocan frases de texto visible CON ESPACIOS,
# de modo que identificadores funcionales como __HERMES_PLUGIN_SDK__ o variables
# HERMES_DASHBOARD/HERMES_HOME quedan intactos.
#
# Nota: en el despliegue v3 el dashboard de Hermes va DESACTIVADO (la UI de cliente
# es LibreChat). Este parche es defensa en profundidad y deja grep-cero de
# "Nous Research" en ui-tui/dist y hermes_cli/web_dist (ver VERIFICATION.md / G2).
FROM nousresearch/hermes-agent:latest

RUN set -eu; \
    for d in /opt/hermes/ui-tui/dist /opt/hermes/hermes_cli/web_dist; do \
      [ -d "$d" ] || continue; \
      grep -rIl -e "Nous Research" -e "Messenger of the Digital Gods" -e "Hermes Teal" -e "Hermes Agent" "$d" 2>/dev/null \
      | while IFS= read -r f; do \
          sed -i \
            -e 's/Messenger of the Digital Gods/Maquinaria Especial Burgos/g' \
            -e 's/Nous Research/Acme Maquinaria Especial/g' \
            -e 's/Hermes Teal/Acme Acero/g' \
            -e 's/Hermes Agent/Acme Agent/g' \
            "$f"; \
        done; \
    done; \
    rem=$(grep -rIl "Nous Research" /opt/hermes/ui-tui/dist /opt/hermes/hermes_cli/web_dist 2>/dev/null | wc -l); \
    echo "[acme-fork] branding patched; files still containing 'Nous Research' on served paths: $rem"; \
    [ "$rem" = "0" ] || { echo "[acme-fork] ERROR: forbidden string remains"; exit 1; }
