# acme-hermes-webui:local — MIT fork of nesquena/hermes-webui with Acme branding.
# Upstream pin: dc90ec9be4f2691a60d2413350405f2758a340a2
#
# Build the Lever: clone upstream, apply scripts/patch-webui-branding.sh, bake image.

FROM alpine:3.21 AS source
RUN apk add --no-cache bash git librsvg
WORKDIR /src
ARG HERMES_WEBUI_SHA=dc90ec9be4f2691a60d2413350405f2758a340a2
RUN git clone --depth 50 https://github.com/nesquena/hermes-webui.git . \
    && git checkout "${HERMES_WEBUI_SHA}"

COPY scripts/patch-webui-branding.sh /patch-webui-branding.sh
COPY seed/plugins/acme-admin/dashboard/dist/logo.svg /acme-logo.svg
RUN chmod +x /patch-webui-branding.sh \
    && ACME_LOGO=/acme-logo.svg /patch-webui-branding.sh /src

FROM python:3.12-slim

LABEL maintainer="felipebasurto"
LABEL description="Acme Maquinaria Especial — Hermes WebUI fork (agent-native GUI)"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl rsync git openssh-client xz-utils locales \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8 LC_ALL=C
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8

WORKDIR /apptoo

RUN groupadd -g 1024 hermeswebui \
    && useradd -u 1024 -d /home/hermeswebui -g hermeswebui -G users -s /bin/bash -m hermeswebui \
    && mkdir -p /app /uv_cache /workspace \
    && chown -R hermeswebui:hermeswebui /home/hermeswebui /app /uv_cache /workspace \
    && chmod 0755 /home/hermeswebui \
    && chmod 1777 /app /uv_cache /workspace

COPY --from=source /src/docker_init.bash /hermeswebui_init.bash
RUN chmod 555 /hermeswebui_init.bash && touch /.within_container

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

COPY --from=source /src /apptoo

ARG HERMES_VERSION=acme-local
RUN echo "__version__ = '${HERMES_VERSION}'" > /apptoo/api/_version.py

ENV HERMES_WEBUI_HOST=0.0.0.0
ENV HERMES_WEBUI_PORT=8787
ENV HERMES_WEBUI_BOT_NAME="Asistente Acme"

EXPOSE 8787

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8787/health || exit 1

USER root
CMD ["/hermeswebui_init.bash"]
