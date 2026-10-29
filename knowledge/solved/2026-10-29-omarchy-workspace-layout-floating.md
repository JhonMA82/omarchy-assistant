---
component: hyprland
scope: omarchy
machine: all
tags:
  - hyprland
  - tiling
  - floating
  - workspace-layout
  - omarchy
---

# Las apps se abren flotando (fuera del tiling) en un workspace

## Problema

Al abrir cualquier aplicación, esta aparecía flotante ("desacoplada del tiling")
con un tamaño fijo de ~1100x760 en lugar de tilearse. Ocurría en un monitor
pero no en el otro, lo que parecía un problema de monitores o de la config
Hyprland.

## Causa

No era el monitor ni la config. Omarchy v4 tiene un **workspace layout mode** que
hace flotar todas las apps de un workspace. El keybinding `SUPER + L`
("Cycle workspace layout") cicla el layout del workspace **activo** por
`dwindle` → `scrolling` → `floating`, y cada modo queda guardado en
`~/.local/state/omarchy/workspace-layouts/<id>.lua`.

En este caso `11.lua` contenía:

```lua
o.workspace_mode({ workspace = "11", mode = "floating" })
```

Al cargarse en cada arranque/reload, el workspace 11 (que vive en el monitor
DP-1) flotaba todas sus apps a `min(1100, ancho*0.64) x min(760, alto*0.68)`.
Coincidía con "un monitor" solo porque ese workspace estaba en ese monitor: el
modo es **por número de workspace**, no por monitor. mover el workspace a otra
pantalla no lo arregla.

## Solución validada

Revertir el workspace al modo por defecto (`dwindle`), igual que hace el propio
toggle al ciclar hasta el default (borra el archivo de estado):

```bash
rm -f ~/.local/state/omarchy/workspace-layouts/11.lua
hyprctl reload
```

`workspace_modes.apply()` recoloca tileadas las ventanas que el modo hubiera
floteado. Verificado: la ventana pasó de flotante 1100x760 a tileada
3048x1678 (llena DP-1), `floating=false`, sin errores en
`hyprctl configerrors`.

Alternativa interactiva: con el workspace afectado activo, pulsar `SUPER + L`
hasta volver a *tiling* (o `SUPER + ALT + L` para ciclar hacia atrás). El toggle
hace `rm` del archivo al llegar al default.

## Scope

Comportamiento de Omarchy, aplicable a cualquier máquina con Hyprland. La
solución toca **estado de runtime** (`~/.local/state/`), no dotfiles: no hay
desired state que chezmoi administre ni paquete que registrar.

## Archivos afectados

- `~/.local/state/omarchy/workspace-layouts/11.lua` — eliminado (runtime, fuera
  de chezmoi).

## Verificación

```bash
hyprctl clients -j | jq -r '.[] | [.class,.workspace.name,.floating]|join(" | ")'
hyprctl workspaces -j | jq -r '.[] | "\(.id) \(.monitor) \(.tiledLayout)"'
ls ~/.local/state/omarchy/workspace-layouts/   # debe estar vacío
hyprctl configerrors                          # debe estar vacío
```

## Rollback

Volver a crear el modo floating del workspace (con el workspace activo):

```bash
omarchy-hyprland-workspace-layout-toggle   # cicla dwindle -> scrolling -> floating
```

O crear el archivo a mano con `o.workspace_mode({ workspace = "<id>", mode = "floating" })`
y `hyprctl reload`.

## Git

Sin cambios en el repo: la solución es solo estado de runtime de Omarchy.
Se documenta aquí como conocimiento reutilizable.
