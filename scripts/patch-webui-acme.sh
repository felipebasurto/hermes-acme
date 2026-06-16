#!/usr/bin/env bash
# Idempotent Acme v5 patches for hermes-webui.
# Usage: patch-webui-acme.sh <webui-root>
set -euo pipefail

ROOT="${1:?webui root required}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ACME_LOGO="${ACME_LOGO:-${REPO_ROOT}/seed/plugins/acme-admin/dashboard/dist/logo.svg}" \
  "${SCRIPT_DIR}/patch-webui-branding.sh" "${ROOT}"

cp "${REPO_ROOT}/docker/webui/acme-industrial.css" "${ROOT}/static/acme-industrial.css"

python3 - "${ROOT}" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

root = Path(sys.argv[1])


def read(rel: str) -> str:
    return (root / rel).read_text(encoding="utf-8")


def write(rel: str, text: str) -> None:
    (root / rel).write_text(text, encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        if new in text:
            return text
        raise SystemExit(f"[patch-webui-acme] missing patch target: {label}")
    return text.replace(old, new, 1)


def regex_once(text: str, pattern: str, repl: str, label: str, flags: int = re.S) -> str:
    next_text, count = re.subn(pattern, repl, text, count=1, flags=flags)
    if count == 0:
        if repl in text:
            return text
        raise SystemExit(f"[patch-webui-acme] missing regex target: {label}")
    return next_text


# ── api/auth.py: demo multi-user auth + role metadata ───────────────────────
auth = read("api/auth.py")

auth = replace_once(
    auth,
    """def _load_sessions() -> dict[str, float]:
    \"\"\"Load persisted sessions from STATE_DIR, pruning expired entries.

    Returns an empty dict on any read or parse error so startup is never
    blocked by a corrupt or missing sessions file.
    \"\"\"
    try:
        if _SESSIONS_FILE.exists():
            data = json.loads(_SESSIONS_FILE.read_text(encoding='utf-8'))
            if not isinstance(data, dict):
                raise ValueError('malformed sessions file — expected dict')
            now = time.time()
            return {t: exp for t, exp in data.items()
                    if isinstance(t, str) and isinstance(exp, (int, float)) and exp > now}
    except Exception as e:
        logger.debug(\"Failed to load sessions file, starting fresh: %s\", e)
    return {}
""",
    """def _session_record_expiry(record) -> float:
    \"\"\"Return expiry from legacy float or Acme v5 session metadata.\"\"\"
    if isinstance(record, (int, float)):
        return float(record)
    if isinstance(record, dict) and isinstance(record.get('expires'), (int, float)):
        return float(record.get('expires'))
    return 0.0


def _load_sessions() -> dict[str, object]:
    \"\"\"Load persisted sessions from STATE_DIR, pruning expired entries.

    Acme v5 stores per-session role metadata as
    ``token -> {expires, role, username}``; legacy upstream sessions stored
    ``token -> expiry_float``.  Accept both so existing browsers do not break.
    \"\"\"
    try:
        if _SESSIONS_FILE.exists():
            data = json.loads(_SESSIONS_FILE.read_text(encoding='utf-8'))
            if not isinstance(data, dict):
                raise ValueError('malformed sessions file — expected dict')
            now = time.time()
            return {
                t: record for t, record in data.items()
                if isinstance(t, str) and _session_record_expiry(record) > now
            }
    except Exception as e:
        logger.debug(\"Failed to load sessions file, starting fresh: %s\", e)
    return {}
""",
    "auth load sessions",
)

auth = replace_once(
    auth,
    """def is_auth_enabled() -> bool:
    \"\"\"True if password auth or passkey-only auth is configured.\"\"\"
    return is_password_auth_enabled() or are_passkeys_enabled()
""",
    """def is_acme_demo_auth_enabled() -> bool:
    \"\"\"True when Acme v5 demo login should own the login surface.\"\"\"
    flag = os.getenv('ACME_UI_DEMO_LOGIN', '').strip().lower()
    if flag not in {'1', 'true', 'yes', 'on'}:
        return False
    return bool(
        os.getenv('ACME_ADMIN_PASSWORD', '').strip()
        and os.getenv('ACME_USER_PASSWORD', '').strip()
    )


def verify_acme_credentials(username: str, password: str) -> dict | None:
    \"\"\"Validate Acme demo credentials and return role identity.\"\"\"
    if not is_acme_demo_auth_enabled():
        return None
    username = (username or '').strip().lower()
    password = password or ''
    admin_user = os.getenv('ACME_ADMIN_USERNAME', 'admin').strip().lower() or 'admin'
    user_user = os.getenv('ACME_USER_USERNAME', 'operador').strip().lower() or 'operador'
    admin_pw = os.getenv('ACME_ADMIN_PASSWORD', '')
    user_pw = os.getenv('ACME_USER_PASSWORD', '')
    if username == admin_user and hmac.compare_digest(password, admin_pw):
        return {'role': 'admin', 'username': admin_user, 'display_role': 'Administrador'}
    if username == user_user and hmac.compare_digest(password, user_pw):
        return {'role': 'usuario', 'username': user_user, 'display_role': 'Operador'}
    return None


def is_auth_enabled() -> bool:
    \"\"\"True if Acme demo auth, password auth, or passkey-only auth is configured.\"\"\"
    return is_acme_demo_auth_enabled() or is_password_auth_enabled() or are_passkeys_enabled()
""",
    "auth Acme helpers",
)

auth = replace_once(
    auth,
    """def create_session() -> str:
    \"\"\"Create a new auth session. Returns signed cookie value.\"\"\"
    token = secrets.token_hex(32)
    with _SESSIONS_LOCK:
        _sessions[token] = time.time() + _resolve_session_ttl()
        _save_sessions(_sessions)
    sig = hmac.new(_signing_key(), token.encode(), hashlib.sha256).hexdigest()
    return f\"{token}.{sig}\"
""",
    """def create_session(role: str = 'admin', username: str = 'admin') -> str:
    \"\"\"Create a new auth session. Returns signed cookie value.\"\"\"
    token = secrets.token_hex(32)
    expires = time.time() + _resolve_session_ttl()
    safe_role = role if role in {'admin', 'usuario'} else 'admin'
    safe_username = (username or safe_role).strip()[:80] or safe_role
    with _SESSIONS_LOCK:
        _sessions[token] = {
            'expires': expires,
            'role': safe_role,
            'username': safe_username,
        }
        _save_sessions(_sessions)
    sig = hmac.new(_signing_key(), token.encode(), hashlib.sha256).hexdigest()
    return f\"{token}.{sig}\"
""",
    "auth create_session",
)

auth = replace_once(
    auth,
    """def _prune_expired_sessions():
    \"\"\"Remove all expired session entries to prevent unbounded memory growth.\"\"\"
    now = time.time()
    with _SESSIONS_LOCK:
        expired = [t for t, exp in _sessions.items() if now > exp]
        if expired:
            for token in expired:
                _sessions.pop(token, None)
            _save_sessions(_sessions)
""",
    """def _prune_expired_sessions():
    \"\"\"Remove all expired session entries to prevent unbounded memory growth.\"\"\"
    now = time.time()
    with _SESSIONS_LOCK:
        expired = [t for t, record in _sessions.items() if now > _session_record_expiry(record)]
        if expired:
            for token in expired:
                _sessions.pop(token, None)
            _save_sessions(_sessions)
""",
    "auth prune sessions",
)

auth = replace_once(
    auth,
    """    with _SESSIONS_LOCK:
        expiry = _sessions.get(token)
        if not expiry or time.time() > expiry:
            _sessions.pop(token, None)
            _save_sessions(_sessions)
            return False
    return True
""",
    """    with _SESSIONS_LOCK:
        record = _sessions.get(token)
        expiry = _session_record_expiry(record)
        if not expiry or time.time() > expiry:
            _sessions.pop(token, None)
            _save_sessions(_sessions)
            return False
    return True


def get_session_identity(cookie_value: str | None) -> dict:
    \"\"\"Return Acme role identity for a valid WebUI auth cookie.\"\"\"
    if not cookie_value or not verify_session(cookie_value):
        return {'role': 'anonymous', 'username': '', 'display_role': ''}
    token = _session_token_from_cookie_value(cookie_value)
    if not token:
        return {'role': 'anonymous', 'username': '', 'display_role': ''}
    with _SESSIONS_LOCK:
        record = _sessions.get(token)
    if isinstance(record, dict):
        role = record.get('role') if record.get('role') in {'admin', 'usuario'} else 'admin'
        username = str(record.get('username') or role)
    else:
        role = 'admin'
        username = 'admin'
    return {
        'role': role,
        'username': username,
        'display_role': 'Administrador' if role == 'admin' else 'Operador',
    }
""",
    "auth verify_session identity",
)

auth = replace_once(
    auth,
    """def clear_auth_cookie(handler) -> None:
    \"\"\"Clear the auth cookie on the response.\"\"\"
    cookie = http.cookies.SimpleCookie()
    name = _resolve_cookie_name()
    cookie[name] = ''
    cookie[name]['httponly'] = True
    cookie[name]['path'] = '/'
    cookie[name]['max-age'] = '0'
    handler.send_header('Set-Cookie', cookie[name].OutputString())
""",
    """def set_acme_role_cookie(handler, role: str) -> None:
    \"\"\"Set a non-secret role cookie used only to prevent UI flash before /api/auth/status.\"\"\"
    cookie = http.cookies.SimpleCookie()
    safe_role = role if role in {'admin', 'usuario'} else 'usuario'
    cookie['acme_role'] = safe_role
    cookie['acme_role']['path'] = '/'
    cookie['acme_role']['samesite'] = 'Lax'
    cookie['acme_role']['max-age'] = str(_resolve_session_ttl())
    if _is_secure_context(handler):
        cookie['acme_role']['secure'] = True
    handler.send_header('Set-Cookie', cookie['acme_role'].OutputString())


def clear_acme_role_cookie(handler) -> None:
    \"\"\"Clear the Acme UI role cookie.\"\"\"
    cookie = http.cookies.SimpleCookie()
    cookie['acme_role'] = ''
    cookie['acme_role']['path'] = '/'
    cookie['acme_role']['max-age'] = '0'
    handler.send_header('Set-Cookie', cookie['acme_role'].OutputString())


def clear_auth_cookie(handler) -> None:
    \"\"\"Clear the auth cookie on the response.\"\"\"
    cookie = http.cookies.SimpleCookie()
    name = _resolve_cookie_name()
    cookie[name] = ''
    cookie[name]['httponly'] = True
    cookie[name]['path'] = '/'
    cookie[name]['max-age'] = '0'
    handler.send_header('Set-Cookie', cookie[name].OutputString())
""",
    "auth role cookie",
)

write("api/auth.py", auth)


# ── api/config.py: Spanish/default workspace/onboarding ─────────────────────
config = read("api/config.py")
config = config.replace('"onboarding_completed": False,', '"onboarding_completed": True,')
config = config.replace(
    '"language": "en",  # UI locale code; must match a key in static/i18n.js LOCALES',
    '"language": os.getenv("HERMES_WEBUI_DEFAULT_LOCALE", "es-ES"),  # Acme v5 forces Spanish demo locale',
)
write("api/config.py", config)


# ── api/routes.py: login, auth status, RBAC, reduced usuario workspace ───────
routes = read("api/routes.py")

acme_login_html = r'''_LOGIN_PAGE_HTML = """<!doctype html>
<html lang="{{LANG}}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Acme Maquinaria Especial — Acceso</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{min-height:100vh;display:flex;align-items:center;justify-content:center;background:#1a1f26;color:#e2e8f0;font-family:"IBM Plex Sans","Segoe UI",system-ui,sans-serif}
.card{width:360px;background:#232a33;border:1px solid #3d4a57;border-radius:4px;padding:32px;box-shadow:none}
.brand{display:flex;align-items:center;gap:12px;margin-bottom:24px}
.logo{width:44px;height:44px;border:1px solid #3d4a57;border-radius:4px;background:#1a1f26;color:#f59e0b;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:18px;letter-spacing:.04em}
h1{font-size:22px;line-height:1.15;font-weight:700;margin:0}
.sub{font-size:13px;color:#94a3b8;margin-top:4px}
label{display:block;font-size:12px;color:#94a3b8;text-transform:uppercase;letter-spacing:.05em;margin:14px 0 6px}
input{width:100%;height:40px;border-radius:4px;border:1px solid #3d4a57;background:#1a1f26;color:#e2e8f0;font-size:15px;padding:0 12px;outline:none}
input:focus{border-color:#2563eb;box-shadow:0 0 0 2px rgba(37,99,235,.34)}
button{width:100%;height:42px;margin-top:18px;border-radius:4px;border:1px solid #2563eb;background:#2563eb;color:#f8fafc;font-size:14px;font-weight:700;cursor:pointer}
button:hover{background:#1d4ed8;border-color:#1d4ed8}
.demo{margin-top:16px;border-top:1px solid #3d4a57;padding-top:12px;color:#94a3b8;font-size:12px;line-height:1.45}
.demo code{font-family:"IBM Plex Mono",ui-monospace,monospace;color:#f59e0b}
.err{display:none;margin-top:12px;border:1px solid rgba(239,68,68,.45);background:rgba(239,68,68,.10);color:#fecaca;border-radius:4px;padding:8px 10px;font-size:13px}
.passkey-login{display:none!important}
</style></head><body>
<div class="card">
  <div class="brand">
    <div class="logo">AC</div>
    <div>
      <h1>Acme Maquinaria Especial</h1>
      <p class="sub">Acceso al asistente de ofertas</p>
    </div>
  </div>
  <form id="login-form" data-invalid-pw="Usuario o contraseña incorrectos" data-conn-failed="No se pudo conectar con el servidor">
    <label for="user">Usuario</label>
    <input type="text" id="user" placeholder="admin u operador" autocomplete="username" autofocus>
    <label for="pw">Contraseña</label>
    <input type="password" id="pw" placeholder="Contraseña demo" autocomplete="current-password">
    <button type="submit">Entrar al panel Acme</button>
    <button type="button" id="passkey-login" class="passkey-login">Entrar con passkey</button>
  </form>
  <div class="err" id="err"></div>
  <div class="demo">Cuentas demo: <code>admin / acme-admin-demo</code><br><code>operador / acme-user-demo</code></div>
</div>
<script src="static/login.js?v={{WEBUI_VERSION}}"></script>
</body></html>"""'''

routes = regex_once(
    routes,
    r'_LOGIN_PAGE_HTML = """<!doctype html>.*?</body></html>"""',
    acme_login_html,
    "routes login html",
)

routes = routes.replace('_lang = _settings.get("language", "en")', '_lang = os.getenv("HERMES_WEBUI_DEFAULT_LOCALE", _settings.get("language", "es-ES"))')

acme_routes_helpers = r'''
# ── Acme v5 demo RBAC helpers ────────────────────────────────────────────────
_ACME_USUARIO_WORKSPACE = os.getenv("ACME_USER_WORKSPACE", "/workspace/docs")
_ACME_SESSION_OWNERS_FILE = STATE_DIR / "acme-session-owners.json"


def _acme_identity(handler) -> dict:
    try:
        from api.auth import get_session_identity, parse_cookie
        return get_session_identity(parse_cookie(handler))
    except Exception:
        return {"role": "anonymous", "username": "", "display_role": ""}


def _acme_role(handler) -> str:
    role = str((_acme_identity(handler) or {}).get("role") or "anonymous")
    return role if role in {"admin", "usuario"} else "anonymous"


def _acme_is_usuario(handler) -> bool:
    return _acme_role(handler) == "usuario"


def _acme_forbidden_response(handler) -> bool:
    return j(
        handler,
        {
            "error": "Acceso reservado a administrador",
            "acme_role": _acme_role(handler),
        },
        status=403,
    )


def _acme_deny_if_needed(handler, method: str, parsed) -> bool:
    if not _acme_is_usuario(handler):
        return False
    path = parsed.path or "/"
    if path in {"/", "/index.html", "/login", "/health", "/manifest.json", "/manifest.webmanifest", "/sw.js", "/favicon.ico"}:
        return False
    if path.startswith(("/static/", "/session/static/")):
        return False
    if path == "/api/auth/status" or path == "/api/auth/logout":
        return False
    if method == "GET":
        denied_exact = {
            "/api/logs",
            "/api/insights",
            "/api/providers",
            "/api/provider/quota",
            "/api/provider/cost-history",
            "/api/plugins",
            "/api/profiles",
            "/api/profile/active",
            "/api/dashboard/status",
            "/api/dashboard/config",
            "/api/model/auxiliary",
            "/api/models/live",
            "/api/workspaces/suggest",
        }
        denied_prefixes = (
            "/api/crons",
            "/api/kanban",
            "/api/skills",
            "/api/memory",
            "/api/plugins",
            "/api/profiles",
            "/api/profile",
            "/api/providers",
            "/api/provider/",
            "/api/dashboard/",
        )
        if path in denied_exact or path.startswith(denied_prefixes):
            _acme_forbidden_response(handler)
            return True
        return False
    allowed_posts = {
        "/api/auth/logout",
        "/api/session/new",
        "/api/session/rename",
        "/api/session/delete",
        "/api/session/clear",
        "/api/chat/cancel",
        "/api/client-events/log",
    }
    if method == "POST" and (path in allowed_posts or path.startswith("/api/chat/")):
        return False
    _acme_forbidden_response(handler)
    return True


def _acme_usuario_settings(settings: dict) -> dict:
    safe = dict(settings)
    safe.update({
        "language": "es",
        "theme": "dark",
        "skin": "acme-industrial",
        "default_workspace": _ACME_USUARIO_WORKSPACE,
        "hidden_tabs": ["tasks", "kanban", "skills", "memory", "profiles", "todos", "insights", "logs", "settings"],
        "tab_order": ["chat", "workspaces"],
        "acme_role": "usuario",
        "show_cli_sessions": False,
        "show_cron_sessions": False,
        "show_previous_messaging_sessions": False,
    })
    for key in (
        "password_env_var",
        "dashboard_plugins",
        "provider_quota",
        "api_key",
    ):
        safe.pop(key, None)
    return safe


def _acme_usuario_workspaces_payload() -> dict:
    return {
        "workspaces": [
            {
                "name": "Documentación Acme",
                "path": _ACME_USUARIO_WORKSPACE,
                "is_default": True,
                "readonly": True,
            }
        ],
        "last": _ACME_USUARIO_WORKSPACE,
        "terminal_remote_backend": _terminal_remote_backend_enabled(),
        "readonly": True,
    }


def _acme_load_session_owners() -> dict:
    try:
        if _ACME_SESSION_OWNERS_FILE.exists():
            data = json.loads(_ACME_SESSION_OWNERS_FILE.read_text(encoding="utf-8"))
            return data if isinstance(data, dict) else {}
    except Exception:
        logger.debug("Failed to load Acme session owners", exc_info=True)
    return {}


def _acme_save_session_owners(owners: dict) -> None:
    try:
        _ACME_SESSION_OWNERS_FILE.parent.mkdir(parents=True, exist_ok=True)
        _ACME_SESSION_OWNERS_FILE.write_text(json.dumps(owners, ensure_ascii=False, indent=2), encoding="utf-8")
    except Exception:
        logger.debug("Failed to save Acme session owners", exc_info=True)


def _acme_record_session_owner(session_id: str | None, handler) -> None:
    if not session_id:
        return
    identity = _acme_identity(handler)
    username = str(identity.get("username") or "").strip()
    role = str(identity.get("role") or "")
    if not username:
        return
    owners = _acme_load_session_owners()
    owners[str(session_id)] = {"username": username, "role": role}
    _acme_save_session_owners(owners)


def _acme_filter_session_response(handler, response: dict) -> dict:
    if not _acme_is_usuario(handler):
        return response
    username = str((_acme_identity(handler) or {}).get("username") or "").strip()
    owners = _acme_load_session_owners()
    sessions = []
    for item in response.get("sessions", []) or []:
        sid = str(item.get("session_id") or "")
        owner = owners.get(sid)
        if owner and owner.get("username") == username:
            sessions.append(item)
    filtered = dict(response)
    filtered["sessions"] = sessions
    filtered["active_profile"] = username or "usuario"
    filtered["other_profile_count"] = 0
    return filtered

'''

routes = replace_once(routes, "# ── Logs endpoint", acme_routes_helpers + "\n# ── Logs endpoint", "routes Acme helper insertion")

routes = replace_once(
    routes,
    """def handle_get(handler, parsed) -> bool:
    \"\"\"Handle all GET routes. Returns True if handled, False for 404.\"\"\"

""",
    """def handle_get(handler, parsed) -> bool:
    \"\"\"Handle all GET routes. Returns True if handled, False for 404.\"\"\"

    if _acme_deny_if_needed(handler, "GET", parsed):
        return True

""",
    "routes handle_get guard",
)

routes = replace_once(
    routes,
    """        return j(handler, settings)
""",
    """        if _acme_is_usuario(handler):
            return j(handler, _acme_usuario_settings(settings))
        return j(handler, settings)
""",
    "routes settings usuario payload",
)

routes = replace_once(
    routes,
    """    if parsed.path == "/api/workspaces":
        return j(
            handler,
            {
                "workspaces": load_workspaces(),
                "last": get_last_workspace(),
                "terminal_remote_backend": _terminal_remote_backend_enabled(),
            },
        )
""",
    """    if parsed.path == "/api/workspaces":
        if _acme_is_usuario(handler):
            return j(handler, _acme_usuario_workspaces_payload())
        return j(
            handler,
            {
                "workspaces": load_workspaces(),
                "last": get_last_workspace(),
                "terminal_remote_backend": _terminal_remote_backend_enabled(),
            },
        )
""",
    "routes workspaces usuario payload",
)

routes = replace_once(
    routes,
    """            diag.stage("response_write")
            return j(handler, _session_list_payload_to_response(payload))
""",
    """            diag.stage("response_write")
            response_payload = _session_list_payload_to_response(payload)
            return j(handler, _acme_filter_session_response(handler, response_payload))
""",
    "routes sessions filter",
)

routes = replace_once(
    routes,
    """        s = new_session(
            workspace=workspace,
            model=model,
            model_provider=model_provider,
            profile=body.get("profile") or None,
            project_id=body.get("project_id") or None,
            worktree_info=worktree_info,
        )
""",
    """        s = new_session(
            workspace=workspace,
            model=model,
            model_provider=model_provider,
            profile=body.get("profile") or None,
            project_id=body.get("project_id") or None,
            worktree_info=worktree_info,
        )
        _acme_record_session_owner(getattr(s, "session_id", None), handler)
""",
    "routes record session owner",
)

routes = replace_once(
    routes,
    """    if parsed.path == "/api/shutdown":
        return _handle_shutdown(handler)
""",
    """    if _acme_deny_if_needed(handler, "POST", parsed):
        return True

    if parsed.path == "/api/shutdown":
        return _handle_shutdown(handler)
""",
    "routes handle_post guard",
)

routes = replace_once(
    routes,
    """    if parsed.path == "/api/auth/status":
        from api.auth import _passkey_feature_flag_enabled, get_password_hash, is_auth_enabled, parse_cookie, verify_session
        from api.passkeys import registered_credentials

        logged_in = False
        auth_enabled = is_auth_enabled()
        if auth_enabled:
            cv = parse_cookie(handler)
            logged_in = bool(cv and verify_session(cv))
        passkey_flag = _passkey_feature_flag_enabled()
        passkeys = registered_credentials() if passkey_flag else []
        password_auth_enabled = get_password_hash() is not None
        return j(handler, {
            "auth_enabled": auth_enabled,
            "logged_in": logged_in,
            "password_auth_enabled": password_auth_enabled,
            "passwordless_enabled": bool(passkeys) and not password_auth_enabled,
            "passkeys_enabled": bool(passkeys),
            "passkeys_count": len(passkeys),
            "passkey_feature_flag": passkey_flag,
        })
""",
    """    if parsed.path == "/api/auth/status":
        from api.auth import _passkey_feature_flag_enabled, get_password_hash, get_session_identity, is_auth_enabled, parse_cookie, verify_session
        from api.passkeys import registered_credentials

        logged_in = False
        identity = {"role": "anonymous", "username": "", "display_role": ""}
        auth_enabled = is_auth_enabled()
        if auth_enabled:
            cv = parse_cookie(handler)
            logged_in = bool(cv and verify_session(cv))
            if logged_in:
                identity = get_session_identity(cv)
        passkey_flag = _passkey_feature_flag_enabled()
        passkeys = registered_credentials() if passkey_flag else []
        password_auth_enabled = get_password_hash() is not None
        return j(handler, {
            "auth_enabled": auth_enabled,
            "logged_in": logged_in,
            "password_auth_enabled": password_auth_enabled,
            "passwordless_enabled": bool(passkeys) and not password_auth_enabled,
            "passkeys_enabled": bool(passkeys),
            "passkeys_count": len(passkeys),
            "passkey_feature_flag": passkey_flag,
            "acme_role": identity.get("role"),
            "acme_username": identity.get("username"),
            "acme_display_role": identity.get("display_role"),
            "default_locale": "es-ES",
            "theme": "acme-industrial",
        })
""",
    "routes auth status",
)

routes = regex_once(
    routes,
    r'''    if parsed\.path == "/api/auth/login":
        from api\.auth import \(
            verify_password,
            create_session,
            set_auth_cookie,
            is_auth_enabled,
        \)
        from api\.auth import _check_login_rate, _record_login_attempt, _clear_login_attempts

        if not is_auth_enabled\(\):
            return j\(handler, \{"ok": True, "message": "Auth not enabled"\}\)
        client_ip = handler\.client_address\[0\]
        if not _check_login_rate\(client_ip\):
            return j\(
                handler,
                \{"error": "Too many attempts\. Try again in a minute\."\},
                status=429,
            \)
        password = body\.get\("password", ""\)
        if not verify_password\(password\):
            _record_login_attempt\(client_ip\)
            return bad\(handler, "Invalid password", 401\)
        _clear_login_attempts\(client_ip\)
        cookie_val = create_session\(\)
        body = json\.dumps\(\{"ok": True\}\)\.encode\(\)
        handler\.send_response\(200\)
        handler\.send_header\("Content-Type", "application/json"\)
        handler\.send_header\("Content-Length", str\(len\(body\)\)\)
        handler\.send_header\("Cache-Control", "no-store"\)
        _security_headers\(handler\)
        set_auth_cookie\(handler, cookie_val\)
        handler\.end_headers\(\)
        handler\.wfile\.write\(body\)
        return True
''',
    '''    if parsed.path == "/api/auth/login":
        from api.auth import (
            verify_password,
            create_session,
            set_auth_cookie,
            set_acme_role_cookie,
            is_auth_enabled,
            is_acme_demo_auth_enabled,
            verify_acme_credentials,
        )
        from api.auth import _check_login_rate, _record_login_attempt, _clear_login_attempts

        if not is_auth_enabled():
            return j(handler, {"ok": True, "message": "Auth not enabled"})
        client_ip = handler.client_address[0]
        if not _check_login_rate(client_ip):
            return j(
                handler,
                {"error": "Demasiados intentos. Prueba de nuevo en un minuto."},
                status=429,
            )
        if is_acme_demo_auth_enabled():
            identity = verify_acme_credentials(body.get("username", ""), body.get("password", ""))
            if not identity:
                _record_login_attempt(client_ip)
                return bad(handler, "Usuario o contraseña incorrectos", 401)
            _clear_login_attempts(client_ip)
            cookie_val = create_session(identity["role"], identity["username"])
            payload = {"ok": True, **identity}
            response_body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            handler.send_response(200)
            handler.send_header("Content-Type", "application/json; charset=utf-8")
            handler.send_header("Content-Length", str(len(response_body)))
            handler.send_header("Cache-Control", "no-store")
            _security_headers(handler)
            set_auth_cookie(handler, cookie_val)
            set_acme_role_cookie(handler, identity["role"])
            handler.end_headers()
            handler.wfile.write(response_body)
            return True
        password = body.get("password", "")
        if not verify_password(password):
            _record_login_attempt(client_ip)
            return bad(handler, "Contraseña incorrecta", 401)
        _clear_login_attempts(client_ip)
        cookie_val = create_session("admin", "admin")
        response_body = json.dumps({"ok": True, "role": "admin", "username": "admin", "display_role": "Administrador"}, ensure_ascii=False).encode("utf-8")
        handler.send_response(200)
        handler.send_header("Content-Type", "application/json; charset=utf-8")
        handler.send_header("Content-Length", str(len(response_body)))
        handler.send_header("Cache-Control", "no-store")
        _security_headers(handler)
        set_auth_cookie(handler, cookie_val)
        set_acme_role_cookie(handler, "admin")
        handler.end_headers()
        handler.wfile.write(response_body)
        return True
''',
    "routes auth login",
)

routes = replace_once(
    routes,
    """    if parsed.path == "/api/auth/logout":
        from api.auth import clear_auth_cookie, invalidate_session, parse_cookie

        cookie_val = parse_cookie(handler)
        if cookie_val:
            invalidate_session(cookie_val)
        body = json.dumps({"ok": True}).encode()
        handler.send_response(200)
        handler.send_header("Content-Type", "application/json")
        handler.send_header("Content-Length", str(len(body)))
        handler.send_header("Cache-Control", "no-store")
        _security_headers(handler)
        clear_auth_cookie(handler)
        handler.end_headers()
        handler.wfile.write(body)
        return True
""",
    """    if parsed.path == "/api/auth/logout":
        from api.auth import clear_acme_role_cookie, clear_auth_cookie, invalidate_session, parse_cookie

        cookie_val = parse_cookie(handler)
        if cookie_val:
            invalidate_session(cookie_val)
        body = json.dumps({"ok": True}).encode()
        handler.send_response(200)
        handler.send_header("Content-Type", "application/json")
        handler.send_header("Content-Length", str(len(body)))
        handler.send_header("Cache-Control", "no-store")
        _security_headers(handler)
        clear_auth_cookie(handler)
        clear_acme_role_cookie(handler)
        handler.end_headers()
        handler.wfile.write(body)
        return True
""",
    "routes auth logout",
)

write("api/routes.py", routes)


# ── static/login.js: username/password Acme login ───────────────────────────
login_js = r'''/* Acme v5 login page — username + password demo roles. */
document.addEventListener('DOMContentLoaded', function () {
  var form = document.getElementById('login-form');
  var user = document.getElementById('user');
  var input = document.getElementById('pw');
  if (!form || !input) return;

  var invalidPw = form.getAttribute('data-invalid-pw') || 'Usuario o contraseña incorrectos';
  var connFailed = form.getAttribute('data-conn-failed') || 'No se pudo conectar con el servidor';

  function showErr(msg) {
    var err = document.getElementById('err');
    if (err) { err.textContent = msg; err.style.display = 'block'; }
  }

  function hideErr() {
    var err = document.getElementById('err');
    if (err) { err.style.display = 'none'; }
  }

  function safeNextPath() {
    try {
      var raw = new URL(window.location.href).searchParams.get('next');
      if (!raw || raw.charAt(0) !== '/' || raw.charAt(1) === '/' || raw.charAt(1) === '\\') return './';
      if (/[\x00-\x1f\x7f\s]/.test(raw)) return './';
      return raw;
    } catch (_) { return './'; }
  }

  async function doLogin(e) {
    e.preventDefault();
    hideErr();
    try {
      var res = await fetch('api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: user ? user.value : '', password: input.value }),
        credentials: 'include',
      });
      var data = {};
      try { data = await res.json(); } catch (_) {}
      if (res.ok && data.ok) {
        try {
          localStorage.setItem('acme_ui_role', data.role || data.acme_role || 'usuario');
          localStorage.setItem('acme_ui_username', data.username || '');
          localStorage.setItem('hermes-lang', 'es');
          localStorage.setItem('hermes-locale', 'es-ES');
          localStorage.setItem('hermes-theme', 'dark');
          localStorage.setItem('hermes-skin', 'acme-industrial');
        } catch (_) {}
        window.location.href = safeNextPath();
      } else {
        showErr(data.error || invalidPw);
      }
    } catch (ex) {
      showErr(connFailed);
    }
  }

  form.addEventListener('submit', doLogin);
  input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') doLogin(e);
  });
});
'''
write("static/login.js", login_js)


# ── static/index.html: early locale/theme, CSS, header role chip, Spanish copy ─
index = read("static/index.html")
index = index.replace('<html lang="en">', '<html lang="es-ES">')
index = replace_once(
    index,
    '<title>Acme Maquinaria Especial</title>',
    '<title>Acme Maquinaria Especial</title>\n<script>(function(){try{localStorage.setItem("hermes-lang","es");localStorage.setItem("hermes-locale","es-ES");localStorage.setItem("hermes-theme","dark");localStorage.setItem("hermes-skin","acme-industrial");var m=document.cookie.match(/(?:^|; )acme_role=([^;]+)/);var r=(m?decodeURIComponent(m[1]):localStorage.getItem("acme_ui_role")||"usuario");document.documentElement.dataset.acmeRole=r;}catch(e){document.documentElement.dataset.acmeRole="usuario";}})()</script>',
    "index early Acme boot",
)
index = replace_once(
    index,
    '<link rel="stylesheet" href="static/style.css?v=__WEBUI_VERSION__">',
    '<link rel="stylesheet" href="static/style.css?v=__WEBUI_VERSION__">\n<link rel="stylesheet" href="static/acme-industrial.css?v=__WEBUI_VERSION__">',
    "index acme css link",
)
index = replace_once(
    index,
    '<button class="app-titlebar-new-chat" id="btnTitlebarNewChat"',
    '<span class="acme-role-chip" id="acmeRoleChip">Operador</span>\n  <button class="app-titlebar-new-chat" id="btnTitlebarNewChat"',
    "index role chip",
)
fallback_replacements = {
    'data-tooltip="Chat"': 'data-tooltip="Conversación"',
    'aria-label="Chat"': 'aria-label="Conversación"',
    'data-label="Chat"': 'data-label="Conversación"',
    '>Chat<': '>Conversación<',
    'data-tooltip="Tasks"': 'data-tooltip="Tareas"',
    'aria-label="Tasks"': 'aria-label="Tareas"',
    'data-label="Tasks"': 'data-label="Tareas"',
    'data-tooltip="Skills"': 'data-tooltip="Procedimientos"',
    'aria-label="Skills"': 'aria-label="Procedimientos"',
    'data-label="Skills"': 'data-label="Procedimientos"',
    '>Skills<': '>Procedimientos<',
    'data-tooltip="Memory"': 'data-tooltip="Memoria"',
    'aria-label="Memory"': 'aria-label="Memoria"',
    'data-label="Memory"': 'data-label="Memoria"',
    'data-tooltip="Spaces"': 'data-tooltip="Documentación"',
    'aria-label="Spaces"': 'aria-label="Documentación"',
    'data-label="Spaces"': 'data-label="Documentación"',
    'data-tooltip="Logs"': 'data-tooltip="Registros"',
    'aria-label="Logs"': 'aria-label="Registros"',
    'data-label="Logs"': 'data-label="Registros"',
    'data-tooltip="Settings"': 'data-tooltip="Configuración"',
    'aria-label="Settings"': 'aria-label="Configuración"',
    '>Settings<': '>Configuración<',
    'placeholder="Filter conversations..."': 'placeholder="Filtrar conversaciones..."',
    'placeholder="Search skills..."': 'placeholder="Buscar procedimientos..."',
    'placeholder="Message Hermes…"': 'placeholder="Escribe tu consulta de oferta…"',
    'Ask anything, run commands, explore files, or manage your scheduled tasks.': 'Pega una RFQ para generar un borrador de oferta técnica.',
    'What files are in this workspace?': 'Mostrar documentación Acme',
    "What's on my schedule today?": 'Revisar tareas de oferta',
    'Help me plan a small project.': 'Preparar borrador de oferta',
    'New conversation': 'Nueva conversación',
    'Reload page': 'Recargar panel',
    'Provider quota': 'Cuota de proveedor',
    'Conversation model': 'Modelo de conversación',
    'Switch profile': 'Cambiar perfil',
    'Switch workspace': 'Cambiar documentación',
    'Workspace, model, reasoning, and context settings': 'Documentación y contexto',
    'Send message': 'Enviar consulta',
}
for old, new in fallback_replacements.items():
    index = index.replace(old, new)
write("static/index.html", index)


# ── static/boot.js: force one dark Acme skin ─────────────────────────────────
boot = read("static/boot.js")
boot = regex_once(
    boot,
    r"const _THEMES=\[.*?\];\nconst _SKINS=\[.*?\];",
    "const _THEMES=[\n  {name:'Acme Industrial', value:'dark', colors:['#1a1f26','#232a33','#f59e0b']},\n];\nconst _SKINS=[\n  {name:'Acme Industrial', value:'acme-industrial', colors:['#1a1f26','#232a33','#f59e0b']},\n];",
    "boot theme skin lists",
)
boot = regex_once(
    boot,
    r"function _normalizeAppearance\(theme,skin\)\{.*?\n\}",
    "function _normalizeAppearance(theme,skin){\n  return {theme:'dark',skin:'acme-industrial'};\n}",
    "boot normalize appearance",
)
write("static/boot.js", boot)


# ── static/panels.js: front-end RBAC and workspace readonly note ─────────────
panels = read("static/panels.js")
acme_panels_helpers = r'''
const ACME_ROLE_PANELS = {
  admin: new Set(['chat','workspaces','skills','memory','tasks','kanban','todos','profiles','logs','insights','settings']),
  usuario: new Set(['chat','workspaces'])
};

function acmeCurrentRole(){
  try{
    const m=document.cookie.match(/(?:^|; )acme_role=([^;]+)/);
    return (m?decodeURIComponent(m[1]):localStorage.getItem('acme_ui_role')||'usuario')==='admin'?'admin':'usuario';
  }catch(_){return 'usuario';}
}

function acmePanelAllowed(panel){
  const allowed=ACME_ROLE_PANELS[acmeCurrentRole()]||ACME_ROLE_PANELS.usuario;
  return allowed.has(panel);
}

function acmeApplyRole(){
  const role=acmeCurrentRole();
  document.documentElement.dataset.acmeRole=role;
  const chip=document.getElementById('acmeRoleChip');
  if(chip) chip.textContent=role==='admin'?'Administrador':'Operador';
  document.querySelectorAll('[data-panel]').forEach(el=>{
    const panel=el.dataset.panel;
    if(!panel)return;
    el.classList.toggle('nav-tab-hidden', !acmePanelAllowed(panel));
    if(!acmePanelAllowed(panel)) el.setAttribute('aria-hidden','true');
    else el.removeAttribute('aria-hidden');
  });
}

document.addEventListener('DOMContentLoaded', ()=>{
  try{
    fetch('api/auth/status',{credentials:'include'})
      .then(r=>r.ok?r.json():null)
      .then(s=>{
        if(s&&s.acme_role){
          localStorage.setItem('acme_ui_role',s.acme_role);
          localStorage.setItem('acme_ui_username',s.acme_username||'');
        }
        acmeApplyRole();
      })
      .catch(()=>acmeApplyRole());
  }catch(_){acmeApplyRole();}
});

'''
panels = replace_once(panels, "const APP_TITLEBAR_KEYS = {", acme_panels_helpers + "\nconst APP_TITLEBAR_KEYS = {", "panels Acme helper insertion")
panels = replace_once(
    panels,
    """async function switchPanel(name, opts = {}) {
  const nextPanel = name || 'chat';
  const prevPanel = _currentPanel;
""",
    """async function switchPanel(name, opts = {}) {
  const nextPanel = name || 'chat';
  if(!acmePanelAllowed(nextPanel)){
    acmeApplyRole();
    if(typeof showToast==='function') showToast('Acceso reservado a administrador');
    if(nextPanel !== 'chat') return switchPanel('chat', Object.assign({}, opts, {bypassSettingsGuard:true}));
    return false;
  }
  const prevPanel = _currentPanel;
""",
    "panels switch guard",
)
panels = replace_once(
    panels,
    """function renderWorkspacesPanel(workspaces){
  const panel=$('workspacesPanel');
  panel.innerHTML='';
""",
    """function renderWorkspacesPanel(workspaces){
  const panel=$('workspacesPanel');
  const acmeReadonly = acmeCurrentRole() === 'usuario';
  panel.innerHTML = acmeReadonly ? '<div class="workspace-readonly-note">Documentación Acme — solo lectura para operador. El administrador gestiona rutas y permisos.</div>' : '';
""",
    "panels workspace readonly intro",
)
panels = replace_once(
    panels,
    """    row.className='ws-row';
    row.dataset.path = w.path;
    row.draggable=true;
""",
    """    row.className='ws-row';
    row.dataset.path = w.path;
    row.draggable = !acmeReadonly;
""",
    "panels workspace draggable",
)
panels = replace_once(
    panels,
    """  if (mode === 'read') {
    const activePath = S.session ? S.session.workspace : '';
""",
    """  if (mode === 'read') {
    if (acmeCurrentRole() === 'usuario') {
      if (ws && ws.path) show(actBtn); else hide(actBtn);
      hide(editBtn); hide(delBtn); hide(cancelBtn); hide(saveBtn);
      return;
    }
    const activePath = S.session ? S.session.workspace : '';
""",
    "panels workspace header buttons",
)
write("static/panels.js", panels)


# ── static/i18n.js: Acme Spanish overrides before loadLocale() ───────────────
i18n = read("static/i18n.js")
acme_i18n = r'''
// Acme v5 Spanish industrial copy overrides.
Object.assign(LOCALES.es, {
  _speech: 'es-ES',
  tab_chat: 'Conversación',
  tab_tasks: 'Tareas',
  tab_kanban: 'Kanban',
  tab_skills: 'Procedimientos',
  tab_memory: 'Memoria',
  tab_workspaces: 'Documentación',
  tab_profiles: 'Perfiles',
  tab_todos: 'Lista actual',
  tab_insights: 'Indicadores',
  tab_logs: 'Registros',
  tab_settings: 'Configuración',
  tab_dashboard: 'Panel externo',
  new_conversation: 'Nueva conversación',
  filter_conversations: 'Filtrar conversaciones...',
  empty_title: 'Pega una RFQ para generar borrador',
  empty_subtitle: 'El asistente preparará un borrador técnico con referencias Acme. Todo queda marcado para revisión humana.',
  suggest_files: 'Mostrar documentación Acme',
  suggest_schedule: 'Revisar tareas de oferta',
  suggest_plan: 'Preparar borrador de oferta',
  settings_title: 'Configuración',
  settings_save_btn: 'Guardar configuración',
  settings_saved: 'Configuración guardada',
  settings_tab_conversation: 'Conversación',
  settings_tab_appearance: 'Apariencia',
  settings_tab_preferences: 'Preferencias',
  settings_tab_plugins: 'Plugins',
  settings_tab_system: 'Sistema',
  settings_tab_help: 'Ayuda',
  settings_label_theme: 'Tema industrial',
  settings_label_skin: 'Identidad visual',
  settings_label_language: 'Idioma',
  settings_desc_tab_visibility: 'El administrador elige las pestañas visibles. El operador solo ve Conversación y Documentación.',
  providers_tab_title: 'Proveedor',
  providers_section_title: 'Proveedor de modelo',
  providers_section_meta: 'El equipo IT configura claves y modelos. El operador no ve esta sección.',
  workspace_choose_path: 'Elegir ruta',
  workspace_choose_path_meta: 'Solo administrador',
  workspace_manage: 'Gestionar documentación',
  workspace_manage_meta: 'Rutas del corpus Acme',
  workspace_new_title: 'Nueva ruta documental',
  workspace_paths_validated_hint: 'Las rutas se validan antes de guardarse. Operador: solo lectura en /workspace/docs.',
  workspace_add_path_placeholder: '/workspace/docs',
  workspace_name_placeholder: 'Nombre visible',
  workspace_path_readonly: 'La ruta documental no se cambia desde perfil operador.',
  workspace_drag_hint: 'Reordenar documentación',
  workspace_remove_confirm_title: 'Quitar documentación',
  workspace_remove_confirm_message: (path) => `Quitar ${path} de la lista de documentación?`,
  search_skills: 'Buscar procedimientos...',
  skills_empty: 'No hay procedimientos disponibles.',
  new_skill: 'Nuevo procedimiento',
  skill_deleted: 'Procedimiento eliminado',
  logs_tail: 'Líneas',
  login_title: 'Acceso',
  login_subtitle: 'Acceso al asistente de ofertas',
  login_placeholder: 'Contraseña demo',
  login_btn: 'Entrar al panel Acme',
  login_invalid_pw: 'Usuario o contraseña incorrectos',
  login_conn_failed: 'No se pudo conectar con el servidor',
  onboarding_title: 'Bienvenido al Panel Acme',
  onboarding_lead: 'Configuración inicial industrial: proveedor, documentación y contraseña de demo.',
  onboarding_notice_finish: 'El administrador puede volver a Configuración para ajustar modelo y gateway.',
  composer_mobile_workspace: 'Documentación',
  composer_mobile_model: 'Modelo',
  session_toolsets: 'Herramientas de sesión',
  session_toolsets_desc: 'Usa los valores del perfil activo o selecciona herramientas para esta sesión.',
  session_toolsets_global: 'Valores del perfil activo',
  session_toolsets_profile_defaults: 'Valores del perfil activo',
  session_toolsets_custom: 'Ajuste manual',
  session_toolsets_use_profile_defaults: 'Usar valores del perfil activo',
  session_toolsets_configured_servers: 'Servidores MCP configurados',
  session_toolsets_loading_servers: 'Cargando servidores configurados...',
  session_toolsets_no_configured_servers: 'No hay servidores MCP configurados',
  session_toolsets_apply: 'Aplicar',
  session_toolsets_clear: 'Usar valores por defecto',
  session_toolsets_applied: 'Herramientas actualizadas',
  session_toolsets_cleared: 'Usando valores del perfil activo',
  session_toolsets_failed: 'No se pudieron actualizar herramientas: ',
  approval_gateway_unsupported: 'Las aprobaciones requieren un gateway más reciente.',
  goal_evaluating_progress: 'Evaluando avance del objetivo…',
  goal_working_toward: 'Trabajando hacia el objetivo…',
  goal_continuing_toast: 'Continuando el objetivo…',
  goal_status_none: 'No hay objetivo activo. Define uno con /goal <texto>.',
  goal_cleared: 'Objetivo borrado.',
  goal_no_goal: 'No hay objetivo activo.',
  tree_view: 'Árbol',
  raw_view: 'Texto',
  parse_failed_note: 'No se pudo interpretar',
  mcp_servers_title: 'Servidores MCP',
  mcp_servers_desc: 'Gestiona servidores MCP configurados.',
  mcp_tools_title: 'Herramientas MCP',
  mcp_tools_desc: 'Busca herramientas conocidas en servidores MCP activos.',
  mcp_tools_search_placeholder: 'Buscar herramientas por nombre, servidor o descripción…',
  mcp_tools_no_tools: 'No hay herramientas MCP disponibles.',
  mcp_tools_no_matches: 'No hay herramientas MCP que coincidan.',
});

'''
i18n = replace_once(i18n, "// Apply saved locale immediately so there's no flash of English on reload.\nloadLocale();", acme_i18n + "\n// Apply saved locale immediately so there's no flash of English on reload.\nloadLocale();", "i18n Acme overrides")
write("static/i18n.js", i18n)


# ── Build asserts ───────────────────────────────────────────────────────────
required = [
    "static/acme-industrial.css",
    "static/login.js",
    "api/auth.py",
    "api/routes.py",
]
for rel in required:
    if not (root / rel).exists():
        raise SystemExit(f"[patch-webui-acme] required file missing after patch: {rel}")

print("[patch-webui-acme] Acme v5 patches complete")
PY

echo "[patch-webui-acme] complete"
