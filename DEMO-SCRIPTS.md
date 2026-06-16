# Demo scripts — Acme Agent v5

## Demo cliente 5–6 minutos

**Objetivo:** mostrar interfaz industrial, español, dos roles y flujo RFQ documentado aunque el modelo LLM no esté configurado.

### 0:00 — Arranque

```bash
make build
make up
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8787/login
```

Mensaje: “El stack arranca con `acme-agent` como gateway y `acme-webui` como panel cliente en español.”

### 0:30 — Login administrador

- URL: `http://localhost:8787/login`
- Usuario: `admin`
- Contraseña: `acme-admin-demo`

Mostrar:

- Header `Acme Maquinaria Especial`.
- Chip **Administrador**.
- Rail completo:
  - Conversación
  - Documentación
  - Procedimientos
  - Memoria
  - Tareas / Kanban / Lista actual
  - Perfiles
  - Registros
  - Indicadores
  - Configuración

### 2:00 — Configuración admin

Entrar en **Configuración** y recorrer:

- Conversación/modelo.
- Proveedor.
- Apariencia industrial Acme.
- Sistema/gateway.

Frase: “Aquí configura IT; el operador no ve esto.”

### 2:30 — Documentación

Abrir **Documentación** y mostrar corpus:

- `/workspace/docs/proyecto-AC-2024-017.md`
- `/workspace/docs/tarifas-mecanica.md`
- `/workspace/docs/tarifas-automatizacion.md`

Señalar:

- `AC-2024-017`
- 120 uds/min
- plazo real 18 semanas
- margen 21,4 %

### 3:00 — RFQ admin

En **Conversación**, pegar:

```text
Buenos días,

Necesitamos línea de envasado para bandejas 400×300 mm, 120 uds/min,
cambio de formato rápido. Ambiente lavado. Plazo 14 semanas.
¿Precio y plazo orientativo?

Saludos, Compras — Hostelería Industrial Norte S.L.
```

Si no hay LLM:

- Mostrar error/banner discreto.
- Decir: “La experiencia de demo no depende de la key. El administrador configura el proveedor después.”

Si hay LLM:

- Buscar `BORRADOR`.
- Buscar `AC-2024-017`.
- Buscar advertencia plazo 14 vs 18 semanas.
- Buscar margen objetivo ≥ 18 %.

### 4:00 — Login operador

Logout y login:

- Usuario: `operador`
- Contraseña: `acme-user-demo`

Mostrar:

- Chip **Operador**.
- Rail reducido: solo **Conversación** y **Documentación**.
- No hay rueda de Configuración.
- No hay selector modelo/API keys/plugins/shutdown.

Intento técnico:

```bash
curl -b cookies-operador.txt -w "%{http_code}\n" http://localhost:8787/api/logs
```

Resultado esperado: `403`.

### 5:20 — RFQ operador

Pegar la misma RFQ. El operador trabaja desde chat y documentación, sin superficies de ingeniería.

### 5:45 — Verificación

```bash
./scripts/verify-branding.sh
./scripts/verify-spanish.sh
```

Ambos deben acabar en:

```text
== ALL PASS ==
```

### 6:00 — Cierre

“Interfaz industrial, español, dos roles, lista para planta Acme Burgos.”

## Reset demo

```bash
make down
sudo rm -rf data/hermes
make up
```
