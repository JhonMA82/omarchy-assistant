---
component: hyprland
scope: machines
machine: omarchy
tags:
  - chezmoi
  - monitores
  - reset
  - omarchy-refresh
---

# `omarchy refresh hyprland` resetea monitores, escala y gaps

## Problema

Tras ejecutar comandos de OpenDeck, la segunda pantalla perdió su configuración (posición, orientación y escala) y el escritorio quedó con los valores por defecto de Omarchy. El usuario sospechó que OpenDeck había modificado algo.

## Causa

OpenDeck no fue el responsable. A las 11:49:25 se ejecutó `omarchy-refresh-hyprland`, que copia los defaults de Omarchy (`/usr/share/omarchy/config/hypr/`) sobre los 7 archivos de `~/.config/hypr/`. El disparador probable es la entrada del menú de Omarchy **Update → Hyprland** (`update.config.hyprland` en `/usr/share/omarchy/default/omarchy/omarchy-menu.jsonc`), que lanza `omarchy-refresh-hyprland` en una terminal flotante.

Firma para reconocerlo en el futuro:

- Backups con el patrón `.bak.<epoch>` (creado por `/usr/share/omarchy/bin/omarchy-refresh-config`), todos con el mismo timestamp.
- Backup solo en los archivos que difieren del default; `omarchy-refresh-config` borra el `.bak` cuando el archivo era idéntico al default. Por eso un `bindings.lua` sin backup significa que nunca tuvo personalizaciones, no que se perdieron.

Con chezmoi como fuente de verdad, `omarchy refresh <app>` siempre gana el default de Omarchy y descarta la capa del repo. Los atajos no se pierden: `bindings.lua` es un archivo de overrides sobre `default.hypr.bindings`, así que los atajos de Omarchy se mantienen aunque el archivo se resetee.

## Solución validada

Restaurar desde la capa chezmoi de la máquina, que ya contenía la configuración correcta:

```bash
chezmoi apply --force --source "<repo>/home/profiles/machines/omarchy"
hyprctl reload
```

`--force` es necesario cuando el archivo cambió después de la última escritura de chezmoi: sin él chezmoi pide confirmación por TTY y falla en entornos sin terminal interactivo.

## Scope

machines: el reset afecta a `~/.config/hypr/`, y la configuración correcta de monitores vive en la capa `machines/<perfil>`. La trampa del comando es común a cualquier capa que administer `hypr/`.

## Archivos afectados

- `knowledge/solved/2026-09-28-omarchy-refresh-hyprland-resetea-monitores.md` (nuevo)
- `AGENTS.md` (prohibición explícita de `omarchy refresh hyprland`)
- Sin cambios de configuración: la capa `home/profiles/machines/omarchy/dot_config/hypr/` ya era correcta.

## Verificación

- `chezmoi --source "<repo>/home/profiles/machines/omarchy" status` → sin salida.
- `hyprctl reload && hyprctl configerrors` → sin errores.
- `hyprctl monitors` → DP-1 (Lenovo 4K) en `0x0` con `scale: 1.25`; HDMI-A-1 (Dell) en `3072x0` con `transform: 3`.
- `hyprctl getoption general:gaps_in` → `3 3 3 3` (default de Omarchy: 5).
- `hyprctl getoption cursor:default_monitor` → `str: DP-1`.
- Validación manual del usuario: segunda pantalla en vertical a la derecha del monitor principal.

## Rollback

Los backups del propio refresh siguen en `~/.config/hypr/*.bak.<epoch>`. Para volver al estado anterior: `cp ~/.config/hypr/<archivo>.bak.<epoch> ~/.config/hypr/<archivo>` y `hyprctl reload`. Para volver a los defaults de Omarchy: `omarchy refresh hyprland`.

## Git

- Sin commit: la solución no modificó la configuración administrada por chezmoi, solo documentación.
