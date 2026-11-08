---
component: omadeck
scope: machines/omarchy
machine: omarchy
tags:
  - omadeck
  - stream-deck
  - hex
  - dictado
  - push-to-talk
commit: adfb317
---

# Tecla push-to-talk de Hex en la Stream Deck (omadeck)

## Problema

Se quería una tecla en la Stream Deck que iniciara el dictado de Hex y lo
detuviera al soltarla, con el mismo comportamiento que el atajo de teclado
Control+Command+X de Hex (`control+command+x` en su configuración).

## Causa

- Hex es una app de dictado que corre oculta y expone su CLI por un socket
  propio (`hex dictation start|stop|toggle`).
- En Hyprland el portal GlobalShortcuts no asigna las teclas de Hex, por eso el
  atajo de teclado se resuelve con `o.bind_hold(...)` en `hypr/bindings.lua`
  ejecutando el CLI.
- Una tecla de la deck no puede reenviar un chord con Super: `wtype` no lo
  maneja de forma fiable en esta máquina. La vía correcta es ejecutar el CLI de
  Hex directamente, sin emular teclas.
- omadeck corre las acciones `app` de forma desacoplada (vía `uwsm-app`) y
  soporta `[key.on_release]`, que es justo lo que necesita el push-to-talk.

## Solución validada

En la página Home de `~/.config/omadeck/config.toml`, tecla `index = 9`:

```toml
[[key]]
index = 9
label = "Dictado"
glyph = "󰍬"

[key.action]
type = "app"
command = "/home/juan/Downloads/hex dictation start"

[key.on_release]
type = "app"
command = "/home/juan/Downloads/hex dictation stop"
```

- `index = 9` es el hueco libre de la Home (fila media, a la derecha de Herdr).
- El glyph `󰍬` (U+F036C, `nf-md-microphone`) se verificó con la JetBrainsMono
  Nerd Font del tema.
- Hex tiene «Launch at login» activo, así que la tecla no necesita arrancarlo.
- La tecla del teclado `SUPER + CTRL + X` quedó en `bindings.lua` como
  push-to-talk equivalente; no se agregó otro atajo de teclado.

Config del deck consolidada con `chezmoi add` desde el archivo vivo (la app de
omadeck escribe `~/.config/omadeck/config.toml` directamente). Ver también
`2026-10-30-omadeck-stream-deck-icono-dinamico.md` para el layout anterior de la
página Monitors.

## Scope

`machines/omarchy` (Stream Deck y Hyprland de esta máquina). No es una
convención para todas las máquinas.

## Archivos afectados

- `home/profiles/machines/omarchy/dot_config/omadeck/config.toml`
- `home/profiles/machines/omarchy/dot_config/omadeck/icons/herdr-app.svg`
- `home/profiles/machines/omarchy/dot_config/hypr/bindings.lua`
- `home/profiles/machines/omarchy/dot_config/omarchy/private_shell.json`
  (sincronización del estado efectivo del shell; commit aparte)

## Verificación

- `python3 -c "import tomllib; tomllib.load(...)"` sobre el config: válido.
- `omadeckd` recargó el config y `omadeckd snapshot` muestra la tecla
  «Dictado» con el micrófono en la Home.
- `jq empty ~/.config/omarchy/shell.json`: válido.
- `hyprctl reload` + `hyprctl configerrors`: sin errores.
- `scripts/verify`: `State: HEALTHY`.
- El usuario validó en hardware que la tecla inicia y detiene el dictado.

## Rollback

Quitar el bloque `[[key]]` con `index = 9` del source y reaplicar la capa:

```bash
chezmoi apply --force --source "<repo>/home/profiles/machines/omarchy"
```

La tecla de teclado `SUPER + CTRL + X` se revierte quitando el `o.bind_hold`
de Hex en `bindings.lua` y recargando con `hyprctl reload` (nunca
`omarchy refresh hyprland`).

## Git

- `adfb317` feat(omadeck): consolida layout y agrega tecla push-to-talk de Hex
- `9cae128` feat(hypr): enlaza el dictado push-to-talk de Hex
- `cde9166` chore(shell): sincroniza plugins de barra e inactividad
