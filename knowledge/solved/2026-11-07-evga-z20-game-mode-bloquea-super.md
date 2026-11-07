---
component: hyprland
scope: machines/omarchy
machine: omarchy
tags:
  - teclado
  - evga-z20
  - game-mode
  - hyprland
  - atajos
  - super
---

# Atajos de Omarchy sin respuesta: el Game Mode del EVGA Z20 bloquea la tecla Súper

## Problema

En una sesión nueva de Omarchy 4.5.0-3 con Hyprland 0.56.2, **todos los atajos basados
en Súper dejaron de responder** (`SUPER + Return`, `SUPER + Space`, workspaces, menús),
mientras escribir, `Shift` y las teclas multimedia seguían funcionando normalmente.

## Causa

El teclado **EVGA Z20 Elite** tenía activado el **Game Mode**, que bloquea la tecla
Windows/Súper en el firmware del teclado. La tecla nunca llega al compositor: no se
emite ningún keycode para `Super_L`/`Super_R`, así que Hyprland no puede hacer match
de ningún bind con `modmask` Súper. La configuración de Hyprland/Omarchy estaba intacta.

Diagnóstico diferencial que descartó el software:

- 247 binds cargados (`hyprctl binds`) y `hyprctl configerrors` vacío.
- Submap activo `default`; sesión logind `Active=yes`; sin `input-capture` ni
  shortcuts-inhibit.
- Los binds sin modificador disparan (subir volumen cambia el volumen real).
- Los binds se resolvían bien con un teclado virtual (`Escape`, `SUPER+Escape`).

## Solución validada

Pulsar la **tecla “E” (Game Mode)** del Z20 —lateral izquierdo, encima de las teclas
macro E1–E5— hasta que se apague el **LED Game Mode**. Después, `SUPER + Return` y
`SUPER + Space` vuelven a responder.

En el EVGA Z15 el equivalente es `Fn + G`; en el Z20 es la tecla física E.

## Scope

- `machines/omarchy`: específico del teclado conectado a esta máquina.
- Sin cambios en el desired state: la solución es puramente de hardware.

## Archivos afectados

Ninguno. No se modificó configuración de Omarchy, Hyprland ni chezmoi.

## Verificación

- `hyprctl binds` → 247 binds; `hyprctl configerrors` → vacío; `hyprctl submap` → `default`.
- Listener Lua `input.keyboard.key` con Game Mode activo: llegan `z` (52), `Shift_L`
  (50) y `XF86AudioRaiseVolume` (123), pero **no** `Super_L`/`Super_R` (133/134).
- Con el Game Mode desactivado, el usuario validó `SUPER + Return` y el resto de atajos.
- `scripts/verify` → `State: DEGRADED` por drift preexistente en la capa
  `profiles/machines/omarchy` (`hypr/bindings.lua`, `omadeck/config.toml`,
  `omarchy/shell.json`), ajeno a esta solución y anterior a la sesión.

Notas reutilizables para diagnosticar atajos:

- `wtype` no sirve para probar chords reales: sube su propio keymap y los keycodes
  resultantes se resuelven contra el keymap global, así que el keysym no coincide.
- Los binds creados con `hyprctl eval` heredan el submap activo en ese momento.
- Un bind `catchall` dentro de un submap confirma que el pipeline de binds y el
  dispatcher `__lua` funcionan; si dispara, el problema es de entrada, no de config.

## Rollback

No aplica: no hay cambios persistentes que revertir.

## Git

- Solo este registro de knowledge; no hubo commit de configuración.
