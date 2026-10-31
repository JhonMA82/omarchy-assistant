---
component: omadeck
scope: machines/omarchy
machine: omarchy
tags:
  - omadeck
  - stream-deck
  - hyprland
  - monitors
  - dynamic-icon
commit: 0ee7333
---

# Stream Deck (Omadeck): página única de monitores, toggle de un botón e icono dinámico

## Problema

Consolidar la configuración de la Stream Deck con Omadeck (sustituto de OpenDeck) en
Omarchy v4: atajos de workspaces por monitor, funciones de ventana, un único botón para
alternar el foco entre monitores y —validación final— que el icono de la tecla Swap
indicara en qué monitor está el foco, actualizándose también con ratón/teclado.

Omadeck no soporta multi-state keys (a diferencia de OpenDeck): no existe una forma
declarativa de cambiar el icono al pulsar una tecla.

## Causa

- El schema de Omadeck solo tiene `action` + `on_release` por tecla (sin
  `states`/`current_state`), así que el icono es estático en el config.
- Pero el daemon observa `config.toml` con inotify y lo recarga en caliente, y la capa
  Lua de Hyprland expone el evento `monitor.focused`: cualquier cambio de foco puede
  disparar una reescritura del campo `icon`.

## Solución validada

1. **Página única `Monitors`** (las páginas Lenovo/Dell separadas eran idénticas salvo
   el monitor anclado): espacios 1–5 relativos al monitor enfocado
   (`o.workspaces.focus(n)` sin ancla) + funciones de ventana (Max, Close, Float, Prev,
   Next, Width, Pseudo, Scratch) + tecla Swap.
2. **Toggle de un solo botón**: `~/.local/bin/omadeck-toggle-monitor` (jq + hyprctl)
   enfoca el monitor que no está enfocado; con 2 monitores, cada pulsación alterna
   ir/volver.
3. **Icono dinámico**: `~/.local/bin/omadeck-update-swap-icon` (python3) reescribe el
   `icon` de las teclas Swap según el monitor enfocado
   (DP-1 → `icons/monitor-landscape.svg`, HDMI-A-1 → `icons/monitor-portrait.svg`).
   Idempotente: solo escribe si el icono cambió (evita recargas en bucle con el
   watcher), valida el TOML con `tomllib` antes y después, y no toca un config que no
   parsea (edición en curso desde la app).
4. **Hook Lua** en `~/.config/hypr/autostart.lua`:
   `hl.on("monitor.focused", ...)` y `hl.on("hyprland.start", ...)` →
   `hl.exec_cmd(<ruta-absoluta del script>)`. Se activa con `hyprctl reload`
   (nunca `omarchy refresh hyprland`).
5. El glyph `󰢹` queda como respaldo: si la tecla tiene `icon`, el glyph no se renderiza
   (verificado por snapshot), así que ambos campos pueden coexistir.

Hallazgos de soporte de Omadeck reutilizables:

- `type = "script"` usa el campo `path`, no `command`: un `command` rompe el parseo del
   TOML completo y el daemon se queda con el config anterior en silencioso
   (`omadeckd press` → "using an empty config").
- `type = "hyprland"` en Omarchy v4 solo admite dispatchers Lua (`hl.dsp.*`,
  `o.workspaces.*`); para shell va en `type = "script"`.
- El hot-reload no pierde la página actual del deck.
- `omadeckd press KEY [PAGE]` y `omadeckd snapshot FILE.png PAGE` permiten probar sin
   tocar el deck físico.

## Scope

- `machines/omarchy`: nombres de monitor (DP-1, HDMI-A-1), rutas absolutas en
  `/home/juan`, barra (`shell.json` con el ítem `dev.omadeck`; el archivo también
  conserva `io.github.fieldnote-ops.harnessbar`, estado actual de la barra).
- `jq` ya estaba en `packages/common.txt`; `python` se agregó a
  `packages/machines/omarchy.txt` (requerido por el script del icono).
- **WARN**: los binarios `omadeck`/`omadeckd` están instalados manualmente en
  `~/.local/bin` (2026-10-29) y NO existen en repos oficiales de pacman → fuera del
  manifiesto v0.1; instalar desde <https://omadeck.app>.

## Archivos afectados

- `home/profiles/machines/omarchy/dot_config/hypr/autostart.lua` (hook)
- `home/profiles/machines/omarchy/dot_config/omadeck/config.toml`
- `home/profiles/machines/omarchy/dot_config/omadeck/icons/` (37 iconos)
- `home/profiles/machines/omarchy/dot_local/bin/executable_omadeck-toggle-monitor`
- `home/profiles/machines/omarchy/dot_local/bin/executable_omadeck-update-swap-icon`
- `home/profiles/machines/omarchy/dot_config/omarchy/private_shell.json`
- `packages/machines/omarchy.txt` (nuevo)

## Verificación

- `scripts/verify` → `State: HEALTHY`.
- `hyprctl configerrors` → vacío tras `hyprctl reload` (el hook carga sin errores Lua).
- `tomllib` parsea `config.toml` tras la captura.
- End-to-end: `omadeckd press 13 Monitors` alterna el foco y el icono pasa
  landscape ↔ portrait en ~1 s; segunda pulsación restaura.
- Foco por ratón/teclado (dispatch `hl.dsp.focus`) también actualiza el icono.
- Snapshots de Home y Monitors con el icono correcto; journal de omadeckd sin errores.

## Rollback

```bash
cd ~/Dev/omarchy-assistant
git revert <commits de la solución>
chezmoi apply --source "$PWD/home/profiles/machines/omarchy"
hyprctl reload   # retira el hook de autostart.lua
```

Los binarios `omadeck`/`omadeckd` no se tocan; el rollback solo retira config, scripts
e hook.

## Git

- `feat(omadeck): pagina unica de monitores, toggle de monitor e icono dinamico`
- `chore(packages): python para el script del icono dinamico de omadeck`
- `docs(knowledge): omadeck stream deck con icono dinamico por monitor`
