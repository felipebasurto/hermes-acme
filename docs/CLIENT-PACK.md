# Client pack — Acme Agent v5

Paquete demo para **Acme Maquinaria Especial** (ficticio).

## Incluido

| Entregable | Descripción |
|---|---|
| Stack Docker | `acme-agent` + `acme-webui` |
| UI industrial | Tema dark acero/ámbar/azul, IBM Plex, radio 4px |
| Dos perfiles | Administrador y Operador |
| RBAC | Frontend + backend, operador limitado |
| Español | Locale forzado `es-ES`, verify dedicado |
| Corpus | `/workspace/docs` con RFQ, tarifas y AC-2024-017 |
| Skills | 8 `acme-*` |
| Demo RFQ | Guion en `DEMO-SCRIPTS.md` |
| Video | Referencia final en `HANDOFF.md` |

## Cuentas demo

| Perfil | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin` | `acme-admin-demo` |
| Operador | `operador` | `acme-user-demo` |

## Responsabilidades del cliente

1. Configurar proveedor LLM con `make setup` para respuestas reales.
2. Cambiar credenciales demo antes de producción.
3. Mantener revisión humana de todo **BORRADOR**.
4. No publicar el puerto `8642` fuera de red controlada.

## Fuera de alcance

- ERP real.
- Envío automático de ofertas.
- Datos reales de clientes.
- Multi-tenant productivo.

## Verificación cliente

```bash
make build
make up
make verify
```

Esperado: branding y español terminan en `== ALL PASS ==`.
