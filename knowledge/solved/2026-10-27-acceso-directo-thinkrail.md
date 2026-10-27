---
component: thinkrail
scope: common
machine: all
tags:
  - launcher
  - desktop-entry
  - thinkrail
commit: abc7549
---

# Acceso directo en el menú para ThinkRail que abre el navegador sin ventana de terminal

## Problema

ThinkRail solo se lanzaba escribiendo `thinkrail` en una terminal; no existía ninguna entrada en el launcher de Omarchy (`Super + Space`).

## Causa

El launcher solo muestra aplicaciones con archivos `.desktop` en `~/.local/share/applications/`, y ThinkRail no tenía uno.

## Solución validada

Crear `home/common/dot_local/share/applications/thinkrail.desktop` con `Exec=thinkrail`, `Terminal=false` e `Icon=thinkrail`. El binario arranca el engine host y abre el navegador por sí solo; los logs quedan en `~/.thinkrail/logs`, por lo que la ventana de terminal no hace falta (versión inicial con `Exec=kitty -e thinkrail` descartada tras la validación del usuario: no quería la terminal abierta y permanecida).

El icono es el oficial de `https://thinkrail.ai/favicon.svg`, guardado como `home/common/dot_local/share/icons/hicolor/scalable/apps/thinkrail.svg` (directorio hicolor ya usado por `herdr.svg`, sin necesidad de caché nueva).

## Scope

`common` (mismo patrón que `herdr.desktop`: `Exec` sin rutas específicas de máquina). Requisito: `thinkrail` en el PATH de cada equipo (instalado con el instalador propio en `~/.local/bin`, fuera de los repos oficiales de pacman, por eso no se registra en `packages/`). Si ThinkRail solo existe en una máquina, mover la entrada a `machines/<perfil>`.

## Archivos afectados

- `home/common/dot_local/share/applications/thinkrail.desktop` (nuevo)
- `home/common/dot_local/share/icons/hicolor/scalable/apps/thinkrail.svg` (nuevo)

## Verificación

- `desktop-file-validate` sobre el `.desktop` en el repo y en el destino → exit 0.
- `xmllint --noout thinkrail.svg` → SVG bien formado.
- `chezmoi apply --force --source <repo>/home/common` sobre los dos archivos; `chezmoi status <ambos>` vacío → destino sincizado con el desired state.
- Validación manual del usuario: desde `Super + Space` aparece ThinkRail con su icono verde y abre el navegador sin ventana de terminal.
- `scripts/verify` → `State: DEGRADED` por diferencias preexistentes ajenas a esta solución (`.config/fish/config.fish`, `.config/kitty/kitty.conf`, `.config/hypr/looknfeel.lua`, `.config/omarchy/shell.json`); los archivos de esta solución no reportan diferencias.

## Rollback

```bash
git checkout HEAD -- home/common/dot_local/share/applications/thinkrail.desktop \
  home/common/dot_local/share/icons/hicolor/scalable/apps/thinkrail.svg
rm ~/.local/share/applications/thinkrail.desktop \
   ~/.local/share/icons/hicolor/scalable/apps/thinkrail.svg
```

O con chezmoi: `chezmoi --source <repo>/home/common` remove sobre cada archivo y reaplicar.

## Git

- Commit de la solución: `feat(common): add thinkrail menu shortcut` — `abc7549`.
- Patrón relacionado: `knowledge/solved/2026-08-14-acceso-directo-opencode.md` (acceso directo previo en el menú).
