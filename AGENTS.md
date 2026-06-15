# AGENTS — Acme Hermes reference deployment

This repo is a white-labeled **Docker** deployment of the third-party
`nousresearch/hermes-agent` image (RFQ → borrador oferta técnica for the
fictional "Acme Maquinaria Especial"). There is no language package manager,
build step, or test suite — the only artifacts are Docker Compose config, a
seed pack (`seed/`), and helper scripts. See `README.md`, `docs/RUNBOOK.md`, and
`VERIFICATION.md` for standard usage; the `Makefile` defines all commands.

## Cursor Cloud specific instructions

### Docker must be started manually each session
Docker is preinstalled in the VM snapshot but the daemon does **not** auto-start.
Start it once per session (a `dockerd` tmux session is the convention) and make
the socket group-accessible:

```bash
sudo dockerd            # run in the background (e.g. a tmux session)
sudo chmod 666 /var/run/docker.sock
```

### Use Compose v2 and override the Makefile's macOS path
The `Makefile` and `scripts/healthcheck.sh` hardcode
`DOCKER_COMPOSE := /opt/homebrew/bin/docker-compose` (macOS Homebrew v1), which
does not exist here. **docker-compose v1 is not an option** on this VM — v1
fails against Docker Engine 29 with `KeyError: 'ContainerConfig'`. Use the
Compose v2 plugin and override the variable:

```bash
make up   DOCKER_COMPOSE="docker compose"
make down DOCKER_COMPOSE="docker compose"
make logs DOCKER_COMPOSE="docker compose"
```

`make health` will still fail at its first line (`$DOCKER_COMPOSE ps`) because
the path is hardcoded inside the script. Run the checks directly instead:

```bash
docker compose ps
curl -s -o /dev/null -w "%{http_code}\n" -u acme:changeme http://localhost:9119/   # 302 = auth gate up
curl -s -u acme:changeme http://localhost:9119/api/status                          # gateway_state + auth_providers
```

### cgroup v2 caveat → `docker-compose.override.yml`
The VM runs inside a host-imposed **"domain threaded"** cgroup v2 namespace, so
the kernel cannot delegate the `memory`/`io` domain controllers. Compose v2
enforces the committed `docker-compose.yml` `deploy.resources.limits`
(memory 4G / cpus 2.0), which then fails container creation with
`cannot enter cgroupv2 ... with domain controllers -- it is in threaded mode`.
A generated **`docker-compose.override.yml`** (created by the startup update
script; not committed) resets those limits with `limits: !reset null`. Compose
auto-loads it, so `make up` works. These caps were already no-ops in the repo's
intended docker-compose v1 environment. Do not delete this file; if it is
missing, recreate it (or rerun the update script).

### Dashboard access
- URL: `http://localhost:9119` — login `acme` / `changeme` (the same
  credentials satisfy both the HTTP basic-auth layer and the app sign-in page).
- The Gateway **API server on :8642 will not start** without `API_SERVER_KEY`
  (`Refusing to start: API_SERVER_KEY is required`). This is harmless for the
  dashboard/chat demo; `make health`'s `:8642/health` probe returning `000` is
  expected.

### Chat requires an LLM model provider (user secret)
No model provider is configured out of the box. The dashboard, theme, skills,
corpus mount, and message queuing all work, but the chat shows
**"Setup Required — Hermes needs a model provider before the TUI can start a
session"** and the agent cannot reply until a key is added. Configure one with
`make setup DOCKER_COMPOSE="docker compose"` (or `make setup-portal ...`), which
writes `data/hermes/.env` (gitignored). Only then can the canonical RFQ →
borrador flow produce a draft offer.

### Reseed / volume permission gotcha
On first `make up`, `scripts/seed-volume.sh` rsyncs `seed/` → `data/hermes/` as
your host user, then the container chowns `data/hermes/` to uid `10000`. After
the container has run, re-running `make seed` (rsync as the host user) into the
container-owned volume can fail with permission denied. If you need to reseed,
`make down` first, and reset with `sudo rm -rf data/hermes` if necessary. `git`
will also warn it cannot read `data/hermes/` — that volume is runtime-only and
intentionally untracked.
