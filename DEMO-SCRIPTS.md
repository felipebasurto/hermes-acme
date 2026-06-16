# Demo script — Acme Agent v6 ("como Claude, pero Acme")

Demo de 3 minutos. Objetivo: enseñar que el asistente "simplemente funciona" con un
lenguaje familiar tipo Claude/Codex, en español, sin cabina de control. El LLM puede
estar sin clave; el aviso degrada con elegancia.

## 0:00 — Arranque

```bash
make build && make up
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8787/login
```

Frase: "Arranca `acme-agent` (gateway) y `acme-webui` (el asistente en español)."

## 0:20 — Login operador

URL `http://localhost:8787/login`, usuario `operador`, contraseña `acme-user-demo`.

Señalar, como en Claude:

- Una sola barra lateral. **No hay rail de iconos.**
- Arriba: "Conversación" + buscador + lista de conversaciones.
- Abajo: footer con **Documentación** y el rol **Operador**.
- En el centro: "Pega una consulta de oferta o RFQ para empezar".

Frase: "Si Claude no lo enseña en la primera pantalla, Acme tampoco."

## 0:50 — Escribir una RFQ

En el composer de abajo, pegar:

```text
Buenos días, necesitamos una línea de envasado para bandejas 400x300 mm,
120 uds/min, plazo 14 semanas. ¿Precio y plazo orientativo?
```

Enter. Sin clave de modelo, aparece el aviso calmado en español:

```text
Error: Modelo no configurado. Ejecute `hermes model` para seleccionar proveedor…
```

Frase: "La demo no depende de la key. El asistente avisa en español, no se rompe."

## 1:20 — Documentación

Clic en **Documentación** (footer). Mostrar el corpus de solo lectura
(`/workspace/docs`, `AC-2024-017`, tarifas). Clic en el logo **Acme** del header para
volver a la conversación.

Frase: "Un enlace discreto a la documentación, nada de pestañas."

## 1:50 — Login administrador

Logout (`/api/auth/logout`) y login `admin` / `acme-admin-demo`.

Señalar:

- Mismo layout limpio. **Tampoco hay rail.**
- El footer ahora añade **Configuración**. Rol **Administrador**.

## 2:15 — Configuración en 1 clic

Clic en **Configuración** (footer). Recorrer las secciones en español: Conversación,
Apariencia, Preferencias, Proveedor, Sistema, Ayuda.

Frase: "El admin llega a ajustes en un clic. Aquí configura IT el proveedor; el operador
nunca ve esto." Volver con el logo.

## 2:45 — Verificación

```bash
make verify   # branding + español → ALL PASS
```

```text
== ALL PASS ==
== ALL PASS ==
```

## 3:00 — Cierre

"Mismo backend de agente (sesiones, tools, workspace, RBAC), pero una experiencia que se
siente como un asistente que funciona, no como un panel SCADA."

## Reset demo

```bash
make down
sudo rm -rf data/hermes
make up
```
