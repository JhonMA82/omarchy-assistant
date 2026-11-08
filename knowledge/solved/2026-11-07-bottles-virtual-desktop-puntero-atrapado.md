---
component: bottles
scope: machines/omarchy
machine: omarchy
tags:
  - bottles
  - wine
  - xwayland
  - hyprland
  - virtual-desktop
  - puntero
  - dialogos
---

# Bottles: diálogos de programas Windows en posiciones arbitrarias y puntero encerrado en el diálogo

## Problema

En Bottles 67.6 (flatpak) con Hyprland 0.56.2, cualquier programa Windows (probado con
Hornresp, bottle win32 con runner `soda-11.0-10`) presentaba dos síntomas:

- Los diálogos aparecían en posiciones arbitrarias de la pantalla, sin relación con la
  ventana principal.
- Con un diálogo abierto, el puntero quedaba **forzado a no salir** de ese diálogo, así
  que era imposible hacer clic en el otro diálogo abierto.

## Causa

Wine es una aplicación **X11**, no Wayland: todo corre sobre XWayland. De ahí los dos
síntomas.

1. **Posicionamiento**: Wine coloca sus ventanas con coordenadas absolutas de la pantalla
   X11 virtual. Hyprland no respeta esos hints como un WM tradicional y, con DP-1 a escala
   1.25 más un monitor rotado, el mapeo se descoloca. Cada diálogo es una superficie
   XWayland independiente (issue conocido hyprwm/Hyprland#2350).
2. **Confine del puntero**: cuando el diálogo toma captura del ratón, Wine usa
   `XGrabPointer`/`XWarpPointer` (`winex11.drv/mouse.c`: `grab_clipping_window()` y
   `X11DRV_SetCursorPos()`). XWayland lo traduce a *pointer constraints* de Wayland y
   Hyprland confina el cursor a esa superficie. Upstream lo cerró como **NOTOURBUG** (Wine
   bug 59610): Wine no puede usar pointer constraints nativos. No existe opción de
   registro para desactivar el grab en Wine moderno.

## Solución validada

Activar **Virtual Desktop** en el bottle. Todos los programas y sus diálogos pasan a vivir
dentro de **una sola ventana X11**, así que el posicionamiento es coherente y la captura
del puntero queda contenida en la misma superficie donde están ambos diálogos.

Bottles → bottle → **Settings → Display → Advanced Display Settings** → activar
**Virtual Desktop** (Width/Height, p. ej. `1280x720`) → **Save** → relanzar el programa.

Efecto en el bottle (verificado):

```ini
# bottle.yml
Parameters:
    virtual_desktop: true
    virtual_desktop_res: 1280x720
```

```ini
# user.reg
[Software\\Wine\\Explorer]
"Desktop"="Default"

[Software\\Wine\\Explorer\\Desktops]
"Default"="1280x720"
```

Equivalente sin UI, dentro del bottle:

```bash
wine reg add 'HKCU\Software\Wine\Explorer' /v Desktop /d Default
wine reg add 'HKCU\Software\Wine\Explorer\Desktops' /v Default /d 1280x720
```

Descartado como causa: **Mouse Warp** quedó activado (`mouse_warp: true` →
`MouseWarpOverride=enable`) y el problema se resolvió igual. `take_focus` también pasó a
`true` en la misma sesión, pero el cambio determinante fue Virtual Desktop.

## Scope

- `machines/omarchy`: estado interno de Bottles (`~/.var/app/com.usebottles.bottles/`),
  ligado a esta máquina y a la combinación escala 1.25 + monitor rotado.
- Sin cambios en el desired state de chezmoi: `bottle.yml` y el registro del prefijo son
  estado administrado por la aplicación, no dotfiles.

## Archivos afectados

Ninguno en el repositorio. Solo estado de la aplicación:

- `~/.var/app/com.usebottles.bottles/data/bottles/bottles/Hornresp/bottle.yml`
- `~/.var/app/com.usebottles.bottles/data/bottles/bottles/Hornresp/user.reg`

## Verificación

- `hyprctl clients -j`: con el problema, Hornresp y su diálogo eran dos superficies
  XWayland (`xwayland: 1`, clase `steam_proton`) flotantes independientes; con Virtual
  Desktop queda una sola ventana.
- `rg -n 'virtual_desktop|virtual_desktop_res' bottle.yml` → `true` / `1280x720`.
- `rg -n -A3 'Wine\\\\Explorer' user.reg` → `Desktop="Default"` y `Default="1280x720"`.
- Validado manualmente por el usuario: los diálogos se abren sobre la ventana principal y
  el puntero se puede mover entre ellos.
- `scripts/verify` → `State: DEGRADED` por drift preexistente en la capa
  `profiles/machines/omarchy` (`hypr/bindings.lua`, `omadeck/config.toml`,
  `omarchy/shell.json`), ajeno a esta solución y anterior a la sesión.

Notas reutilizables:

- `hyprctl getoption xwayland:force_zero_scaling` → `true` en esta máquina; aun así el
  mapeo Wine↔Hyprland no es fiable con escala fraccionaria y monitor rotado.
- El confine no es permanente: se puede comprobar el estado del puntero con
  `hyprctl dispatch 'hl.dsp.cursor.move({x=...,y=...})'` y `hyprctl cursorpos`. Ojo:
  en Hyprland 0.56 el dispatcher ya es Lua (`hl.dsp.*`), la forma `movecursor x y` falla.
- Si Virtual Desktop no bastara, las alternativas son una `hl.window_rule` de
  `float`+`center` para la clase de Wine, `xrandr --output DP-1 --primary` en autostart,
  gamescope por acceso directo, o el driver Wayland de Wine (experimental).

## Rollback

Desactivar **Virtual Desktop** en el mismo diálogo de Bottles (o `wine reg delete
'HKCU\Software\Wine\Explorer' /v Desktop`) y relanzar el programa.

## Git

- Solo este registro de knowledge; no hubo commit de configuración.
