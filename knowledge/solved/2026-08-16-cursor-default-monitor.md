---
component: hyprland
scope: common
machine: all
tags:
  - cursor
  - monitor
  - multi-monitor
---

# Cursor inicia en monitor secundario al iniciar sesión

## Problema

Con dos monitores (Lenovo DP-1 principal + Dell HDMI-A-1 vertical secundario), el cursor aparecía en el monitor Dell al iniciar sesión en lugar del Lenovo.

## Causa

Hyprland no tenía configurada la opción `cursor:default_monitor`, por lo que colocaba el cursor en el primer monitor detectado (HDMI-A-1) en lugar del monitor principal deseado (DP-1).

## Solución validada

Agregar al final de `~/.config/hypr/hyprland.lua`:

```lua
hl.config({ cursor = { default_monitor = "DP-1" } })
```

El cambio se aplica inmediatamente tras `hyprctl reload` y persiste en reinicios.

## Scope

common: la configuración `cursor:default_monitor` es genérica y aplica a cualquier equipo con múltiples monitores donde se requiera controlar la posición inicial del cursor.

## Archivos afectados

- `~/.config/hypr/hyprland.lua` (override directo del usuario, no administrado por chezmoi en este repo)

## Verificación

- `hyprctl getoption cursor:default_monitor` → `str: DP-1` / `set: true`
- `hyprctl reload && hyprctl configerrors` → sin errores
- Validación manual: cursor aparece en monitor principal (Lenovo DP-1) al iniciar sesión

## Rollback

Eliminar la línea `hl.config({ cursor = { default_monitor = "DP-1" } })` de `~/.config/hypr/hyprland.lua`.

## Git

- Cambio en config live, no administrado por este repo.
