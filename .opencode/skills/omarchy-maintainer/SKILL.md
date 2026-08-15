---
name: omarchy-maintainer
description: "Trigger: omarchy, quickshell, hyprland, ghostty, starship, fish, shell.toml. Aplicar cambios mínimos en la capa de usuario de Omarchy v4 (Quattro) sin tocar defaults internos."
license: Apache-2.0
metadata:
  author: "juan"
  version: "1.1"
---

# Omarchy Maintainer

## Contrato de activación

Activa esta skill al trabajar sobre Omarchy **v4 (Quattro) o posterior** y sus componentes de usuario: Hyprland (config en Lua), el shell Quickshell (bar, launcher, menús, notificaciones, OSD, paneles, lock, polkit), Fish, Starship y Ghostty.

Desde v4 Quattro, Waybar, Walker, Mako, SwayOSD, hyprlock, hypridle, swaybg y polkit-gnome fueron reemplazados por Quickshell: no instalarlos ni configurarlos.

## Reglas duras

- Investigar antes de modificar: leer la configuración actual, logs y convenciones de Omarchy.
- Los archivos de `/usr/share/omarchy` pertenecen al paquete de Omarchy y pacman los sobrescribe en cada actualización: nunca editarlos; sobrescribir el valor en `~/.config` en su lugar.
- Preferir siempre personalizaciones en la capa del usuario; este proyecto es un overlay, no un fork.
- Aplicar cambios mínimos: resolver solo el problema real.

## Ubicaciones típicas del usuario

| Componente | Ubicación |
|---|---|
| Hyprland (Lua) | `~/.config/hypr/hyprland.lua` (+ `bindings.lua`, `monitors.lua`, `input.lua`, `looknfeel.lua`, `autostart.lua`) |
| Shell (bar, paneles, lock, idle) | `~/.config/omarchy/shell.json` |
| Override visual del shell | `~/.config/omarchy/shell.toml` |
| Menú de Omarchy | `~/.config/omarchy/extensions/omarchy-menu.jsonc` |
| Hooks de eventos | `~/.config/omarchy/hooks/<evento>.d/` |
| Terminal por defecto (Foot) | `~/.config/foot/foot.ini` |
| Ghostty (soportado) | `~/.config/ghostty/` |
| Fish | `~/.config/fish/` |
| Starship | `~/.config/starship.toml` |

## Puertas de decisión

| Situación | Acción |
|---|---|
| Existe un override soportado por Omarchy | Usar el override; no editar el archivo interno. |
| El cambio toca `/usr/share/omarchy` | No editarlo: pacman lo sobrescribirá; usar `~/.config`. |
| Personalizar bar, launcher o shell | Preferir `~/.config/omarchy/shell.*` o plugins (`omarchy plugin add`). |
| Aparece waybar/walker/mako/swayosd/hyprlock/hypridle/swaybg/polkit-gnome | Son legacy en v4: usar el equivalente de Quickshell. |
| La modificación podría interferir con actualizaciones upstream | Mantener el cambio en la capa de usuario, mínimo, y anotarlo. |

## Pasos de ejecución

1. Identificar el componente afectado y su ubicación de usuario.
2. Diagnosticar antes de cambiar.
3. Editar solo la capa de usuario con el cambio mínimo.
4. Dejar que el usuario pruebe y valide.
5. Consolidar con `/solved`.

## Contrato de salida

- Resumen del cambio, archivos tocados y motivo.
- Aviso explícito si la personalización podría chocar con actualizaciones upstream.
