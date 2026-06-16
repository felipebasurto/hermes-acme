# DESIGN-ACME — sistema visual del asistente (v6)

Fuente única de verdad (SSOT) del diseño de la GUI de **Acme Maquinaria Especial**.
Cualquier cambio visual se decide aquí antes de tocar CSS o parches.

## Design read

> Leído como: UI de chat de agente para personal administrativo de fábrica, con un
> lenguaje familiar tipo Claude/Codex, inclinado hacia un minimalismo calmado estilo
> documento con acentos industriales Acme sutiles.

Referencias de **patrón** (no copia pixel): Claude.ai (sidebar de sesiones estrecha,
chat centrado, composer fijo abajo, ajustes escondidos en menú), ChatGPT/Codex (la
conversación es el home, sin rail de iconos), Linear (solo el ritmo: spacing, bordes
hairline, foco limpio).

Anti-referencia: panel SCADA con 10+ iconos en rail vertical, etiquetas técnicas,
sensación de cabina de control.

## Atmósfera

Calmado, denso en señal y pobre en chrome. La conversación manda. El acero es el fondo,
el ámbar es **señal** (borrador, aviso, borde de tool card), nunca decoración. Sin
gradientes "AI", sin glassmorphism, sin sombras negras duras.

## Color (tokens)

| Token | Hex | Uso |
|---|---|---|
| `--acme-canvas` | `#14171c` | Lienzo principal del chat (lectura calmada) |
| `--acme-bg` | `#1a1f26` | Superficie del sidebar (acero, un tono sobre el lienzo) |
| `--acme-surface` | `#1f242c` | Composer, inputs, tool cards |
| `--acme-surface-2` | `#262d36` | Hover, burbuja de usuario, item activo |
| `--acme-border` | `#2b333d` | Hairline (separadores, bordes de card) |
| `--acme-border-strong` | `#39434f` | Borde de foco secundario, chip |
| `--acme-text` | `#e6eaf0` | Texto principal |
| `--acme-muted` | `#9aa6b2` | Meta, placeholders, subtítulos |
| `--acme-accent` (ámbar) | `#f59e0b` | SOLO borrador, avisos, borde izq. tool card |
| `--acme-primary` (azul) | `#2563eb` | Acción enviar y primarios, sobrio estilo Claude |
| `--acme-danger` | `#ef4444` | Stop/interrumpir, error |

Regla del ámbar: si un elemento es ámbar y no es señal (borrador, aviso, tool card),
es un error de diseño. Los botones de acción son azules, no ámbar.

## Tipografía

- **UI y cuerpo:** IBM Plex Sans (una sola familia, ya en el proyecto; no se mezcla con Geist).
- **Mono:** IBM Plex Mono para tool cards, código, tablas y referencias `AC-2024-017`.
- **Escala calmada:** 14px UI, 15px cuerpo de mensajes y composer, 13px meta, 12px chips/footer.
  Sin titulares gigantes. El título del header es 15px, no un banner.

## Layout

```
┌───────────────────────────────────────────────────────────┐
│  [▲ Acme] Conversación · Maquinaria Especial   [chip rol]  │  header 52px
├───────────────┬───────────────────────────────────────────┤
│ Conversación + │                                           │
│ [filtrar...]   │            mensajes (max 760px,           │
│                │              columna centrada)            │
│  · sesión 1    │                                           │
│  · sesión 2    │                                           │
│                │                                           │
│ ───────────    │                                           │
│ 🗎 Documentación│                                           │
│ ⚙ Configuración│   ┌─────────────────────────────────┐    │
│ ● Rol          │   │ Escribe tu consulta…       [↑]  │    │  composer
└───────────────┴───└─────────────────────────────────┘────┘
```

- **Sin rail vertical de iconos.** Eliminado por CSS (`.rail{display:none}`) y la barra
  duplicada `.sidebar-nav`. La densidad SCADA desaparece.
- **Sidebar 272px.** Sesiones arriba (home), acciones abajo en un footer.
- **Footer del sidebar** es la única navegación: `Documentación` (todos) y `Configuración`
  (solo admin), más un indicador de rol con punto ámbar. El operador nunca ve el engranaje.
- **Volver al home:** clic en la marca Acme del header (`switchPanel('chat')`) o en el `+`.
- **Mensajes:** columna centrada de ~760px (legibilidad Tufte). Asistente plano sin chrome;
  usuario en burbuja de acero discreta (patrón Claude).

### Decisión de densidad del sidebar: 272px

Se compararon 260px (Claude estrecho) y 280px (cómodo). Elegido **272px**: el corpus Acme
usa títulos largos y referencias `BORRADOR-AC-2024-017-oferta-cliente`, y el personal de
planta suele trabajar en monitores de menor resolución. 272px deja respirar esos títulos sin
sentirse un panel ancho. En <720px baja a 240px.

## Componentes clave

- **Composer:** textarea auto-grow, borde sutil, anillo de foco azul limpio (`0 0 0 2px`),
  botón enviar azul icon-only (nunca ámbar; deshabilitado en acero apagado).
- **Mensajes:** asistente flat (sin fondo ni borde), usuario en burbuja `--acme-surface-2`
  con borde hairline, radio 14px.
- **Tool cards:** card plana, borde izquierdo 3px ámbar (señal), monospace, sin sombra.
- **Empty state:** marca triangular Acme + "Pega una consulta de oferta o RFQ para empezar"
  + un ejemplo concreto en una línea. Sin grid de sugerencias de marketing.
- **Login:** tarjeta centrada, 2 cuentas demo en mono ámbar, cero copy de marketing.
- **Aviso sin LLM:** barra/inline fina ámbar, texto español, nunca modal bloqueante.
- **Chip de rol:** píldora pequeña, contorno, ámbar suave solo para operador.

## Motion

Transiciones 160ms ease-out en hover/focus/activo. Sin bounce, confetti, parallax ni
scroll hijacking.

## Español

`es-ES` por defecto. Copy humano de planta industrial ("Escribe tu consulta de oferta",
"Documentación", "Configuración"), nunca "agente Hermes". `verify-spanish.sh` debe seguir
en `ALL PASS`.

## Anti-patterns (rechazados)

- Rail iconográfico estilo SCADA / militar.
- Añadir pestañas "por si acaso".
- Reintroducir Open WebUI o dashboard Hermes.
- Landing/marketing dentro del agent UI.
- Caduceo Hermes (reemplazado por la marca triangular Acme en header y empty state).
- Botones ámbar por todas partes (el ámbar es solo señal).
- Gradientes purple "AI", glassmorphism, sombras duras.
